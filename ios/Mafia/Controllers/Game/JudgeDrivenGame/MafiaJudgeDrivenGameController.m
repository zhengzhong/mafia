//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaJudgeDrivenGameController.h"
#import "MafiaUpdatePlayerController.h"

#import "MafiaAssets.h"
#import "MafiaGameplay.h"

#import "TSMessage+MafiaAdditions.h"
#import "UIImage+MafiaAdditions.h"
#import "UIView+MafiaAdditions.h"


@implementation MafiaJudgeDrivenGamePlayerCell

- (void)setupWithPlayer:(MafiaPlayer *)player isSelectable:(BOOL)isSelectable isSelected:(BOOL)isSelected {
    // Avatar image.
    UIImage *avatarImage = player.avatarImage;
    if (avatarImage == nil) {
        avatarImage = [MafiaAssets imageOfAvatar:MafiaAvatarDefault];
    }
    if (player.isDead) {
        avatarImage = [avatarImage mafia_grayscaledImage];
    }
    self.avatarImageView.image = avatarImage;
    [self.avatarImageView mafia_makeRoundCornersWithBorder:NO];

    // Player information: name and role.
    self.nameLabel.text = player.displayName;
    self.roleLabel.text = player.role.displayName;
    self.roleImageView.image = [MafiaAssets imageOfRole:player.role];
    [self.roleImageView mafia_makeRoundCornersWithBorder:NO];

    // Selectable and selected status.
    if (!isSelectable) {
        self.checkImageView.image = [MafiaAssets imageOfUnselectable];
    } else if (isSelected) {
        self.checkImageView.image = [MafiaAssets imageOfSelected];
    } else {
        self.checkImageView.image = [MafiaAssets imageOfUnselected];
    }

    // Player status.
    self.justGuardedImageView.image = [MafiaAssets imageOfStatus:MafiaStatusJustGuarded];
    self.unguardableImageView.image = [MafiaAssets imageOfStatus:MafiaStatusUnguardable];
    self.misdiagnosedImageView.image = [MafiaAssets imageOfStatus:MafiaStatusMisdiagnosed];
    self.votedImageView.image = [MafiaAssets imageOfStatus:MafiaStatusVoted];
    self.deadImageView.image = [MafiaAssets imageOfStatus:MafiaStatusDead];

    UIColor *activeColor = [MafiaAssets colorOfStyle:MafiaColorStyleDanger];
    UIColor *inactiveColor = [MafiaAssets colorOfStyle:MafiaColorStyleMuted];

    self.justGuardedImageView.tintColor = (player.isJustGuarded ? activeColor : inactiveColor);
    self.unguardableImageView.tintColor = (player.isUnguardable ? activeColor : inactiveColor);
    self.misdiagnosedImageView.tintColor = (player.isMisdiagnosed ? activeColor : inactiveColor);
    self.votedImageView.tintColor = (player.isVoted ? activeColor : inactiveColor);
    self.deadImageView.tintColor = (player.isDead ? activeColor : inactiveColor);

    // Current role tags.
    NSUInteger tagIndex = 0;
    for (MafiaRole *taggedByRole in player.currentRoleTags) {
        UIImageView *imageView = self.tagImageViews[tagIndex];
        imageView.image = [MafiaAssets smallImageOfRole:taggedByRole];
        [imageView mafia_makeRoundCornersWithBorder:NO];
        ++tagIndex;
    }
    for (NSUInteger i = tagIndex; i < [self.tagImageViews count]; ++i) {
        UIImageView *imageView = self.tagImageViews[i];
        imageView.image = nil;
    }
}

@end


// ------------------------------------------------------------------------------------------------


static NSString *const kStoryboard = @"JudgeDrivenGame";
static NSString *const kControllerID = @"JudgeDrivenGame";

static NSString *const kPlayerCellID = @"PlayerCell";

static NSString *const kUpdatePlayerSegueID = @"UpdatePlayerSegue";


@interface MafiaJudgeDrivenGameController () <MafiaUpdatePlayerControllerDelegate>

@property (strong, nonatomic) MafiaPlayer *playerToUpdate;

@end


@implementation MafiaJudgeDrivenGameController


#pragma mark - Storyboard


+ (instancetype)controller {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboard bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:kControllerID];
}


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;

    // Add long-press gesture support, which will enter "edit" mode of the selected player.
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(mafia_handleLongPress:)];
    gestureRecognizer.minimumPressDuration = 2;  // 2 seconds.
    [self.playersTableView addGestureRecognizer:gestureRecognizer];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self mafia_refreshView];
}


#pragma mark - Public


- (void)startGame:(MafiaGame *)game {
    NSAssert([game isReadyToStart], @"Game is not ready to start.");
    self.game = game;
    self.selectedPlayers = [NSMutableArray arrayWithCapacity:2];
    [self.game startGame];
}


#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.game.playerList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MafiaJudgeDrivenGamePlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlayerCellID forIndexPath:indexPath];
    MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
    MafiaAction *currentAction = [self.game currentAction];
    BOOL isSelectable = [currentAction isPlayerSelectable:player];
    BOOL isSelected = [self.selectedPlayers containsObject:player];
    [cell setupWithPlayer:player isSelectable:isSelectable isSelected:isSelected];
    return cell;
}


#pragma mark - UITableViewDelegate


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.game.winner != MafiaWinnerUnknown) {
        return nil;  // Game is over, none of the rows are selectable.
    }
    MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
    MafiaAction *currentAction = [self.game currentAction];
    return ([currentAction isPlayerSelectable:player] ? indexPath : nil);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
    MafiaAction *currentAction = [self.game currentAction];
    MafiaNumberRange *numberOfChoices = [self mafia_numberOfChoicesForActon:currentAction];
    // Toggle the player between "selected" and "unselected" status.
    if ([self.selectedPlayers containsObject:player]) {
        [self.selectedPlayers removeObject:player];
    } else {
        [self.selectedPlayers addObject:player];
    }
    // If too many players are selected, remove the previously selected one(s).
    while ([self.selectedPlayers count] > numberOfChoices.maxValue) {
        [self.selectedPlayers removeObjectAtIndex:0];
    }
    [self mafia_refreshView];
}


#pragma mark - MafiaUpdatePlayerControllerDelegate


- (void)updatePlayerController:(MafiaUpdatePlayerController *)controller didUpdatePlayer:(MafiaPlayer *)player {
    // If the updated player is currently selected, he may become unselectable, and should be unselected.
    if (![self.selectedPlayers containsObject:player]) {
        return;
    }
    MafiaAction *currentAction = [self.game currentAction];
    if (![currentAction isPlayerSelectable:player]) {
        [self.selectedPlayers removeObject:player];
    }
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kUpdatePlayerSegueID]) {
        [self mafia_prepareViewControllerWithPlayerToUpdate:segue.destinationViewController];
    }
}


#pragma mark - Actions


- (IBAction)nextButtonTapped:(id)sender {
    if ([self.game checkGameOver]) {
        return;  // Do nothing if game is over.
    }

    MafiaAction *currentAction = [self.game currentAction];
    MafiaNumberRange *numberOfChoices = [self mafia_numberOfChoicesForActon:currentAction];
    if ([numberOfChoices isNumberInRange:[self.selectedPlayers count]]) {
        // Execute the current action.
        [currentAction beginAction];
        if ([currentAction isExecutable]) {
            for (MafiaPlayer *player in self.selectedPlayers) {
                [currentAction executeOnPlayer:player];
            }
        }
        MafiaInformation *information = [currentAction endAction];
        if (information != nil) {
            [TSMessage mafia_showMessageAndDetailsOfInformation:information];
        } else {
            [TSMessage mafia_showMessageWithTitle:NSLocalizedString(@"Action Completed", nil) subtitle:nil];
        }
        // Continue to the next action.
        [self.game continueToNextAction];
        [self.selectedPlayers removeAllObjects];
    } else {
        // Cannot continue to next: wrong number of players selected.
        NSString *title = NSLocalizedString(@"Invalid Selections", nil);
        NSString *hint = [NSString stringWithFormat:NSLocalizedString(@"Select %@ player(s)", nil), [numberOfChoices string]];
        [TSMessage mafia_showErrorWithTitle:title subtitle:hint];
    }

    [self mafia_refreshView];
}


- (IBAction)resetButtonTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(@"Are you sure to reset game?", nil)
                         message:nil
                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No. Take me back!", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];

    void (^resetGameBlock)(UIAlertAction *) = ^(UIAlertAction *action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    };
    UIAlertAction *resetGameAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes. Reset the game!", nil)
                                                              style:UIAlertActionStyleDestructive
                                                            handler:resetGameBlock];
    [alertController addAction:resetGameAction];

    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Private: Update Player


/// Handles long-press gesture on a table view cell: enter "edit" mode of the selected player.
-(void)mafia_handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }

    CGPoint point = [gestureRecognizer locationInView:self.playersTableView];
    NSIndexPath *indexPath = [self.playersTableView indexPathForRowAtPoint:point];
    if (indexPath == nil) {
        NSLog(@"Long press on the players table view but not on a row.");
        return;
    }

    MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Update player %@?", nil), player.displayName]
                         message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];

    void (^updatePlayerBlock)(UIAlertAction *) = ^(UIAlertAction *action) {
        self.playerToUpdate = player;  // Remember the player for `prepareForSegue:sender:`.
        [self performSegueWithIdentifier:kUpdatePlayerSegueID sender:self];
    };
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:updatePlayerBlock];
    [alertController addAction:yesAction];

    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:noAction];

    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)mafia_prepareViewControllerWithPlayerToUpdate:(MafiaUpdatePlayerController *)controller {
    [controller setupWithPlayer:self.playerToUpdate];
    controller.delegate = self;
}


#pragma mark - Private


- (MafiaNumberRange *)mafia_numberOfChoicesForActon:(MafiaAction *)action {
    if ([action isExecutable]) {
        return [action numberOfChoices];
    } else {
        return [MafiaNumberRange numberRangeWithSingleValue:0];
    }
}


- (void)mafia_refreshView {
    if (self.game.winner != MafiaWinnerUnknown) {
        // Game is over, winner is known.
        self.title = NSLocalizedString(@"Game Over", nil);
        self.nextBarButtonItem.enabled = NO;
        self.actionLabel.text = NSLocalizedString(@"Game Over", nil);
        self.promptLabel.text = nil;
        [TSMessage mafia_showGameResultWithWinner:self.game.winner];
    } else {
        // Game is still ongoing.
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Round %d", nil), self.game.round];
        self.nextBarButtonItem.enabled = YES;
        MafiaAction *currentAction = [self.game currentAction];
        self.actionLabel.text = [NSString stringWithFormat:@"%@", currentAction];
        if ([currentAction isExecutable]) {
            MafiaNumberRange *numberOfChoices = [self mafia_numberOfChoicesForActon:currentAction];
            self.promptLabel.text = [NSString stringWithFormat:
                NSLocalizedString(@"Select %@ player(s)", nil),
                [numberOfChoices string]];
        } else if (currentAction.role != nil) {
            self.promptLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ not available", nil), currentAction.role];
        } else {
            self.promptLabel.text = NSLocalizedString(@"Continue to next", nil);
        }
    }
    [self.playersTableView reloadData];
}


@end
