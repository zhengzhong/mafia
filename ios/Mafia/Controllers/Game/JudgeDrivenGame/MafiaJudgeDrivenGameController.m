//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaJudgeDrivenGameController.h"

#import "MafiaUpdatePlayerController.h"
#import "MafiaActionSheet.h"
#import "TSMessage+MafiaAdditions.h"
#import "UIImage+MafiaAdditions.h"

#import "MafiaAssets.h"
#import "MafiaGameplay.h"
#import "UIView+MafiaAdditions.h"


@implementation MafiaJudgeDrivenGamePlayerCell

- (void)setupWithPlayer:(MafiaPlayer *)player isSelected:(BOOL)isSelected {
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

    // Selected?
    if (isSelected) {
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
        imageView.image = [MafiaAssets imageOfRole:taggedByRole];
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
    // Remove extra top padding of the players table view. Note: the auto adjustment of scroll
    // view's content inset takes care of both navigation bar and tab bar. Once disabled, we need
    // to ensure the top and the bottom manually.
    //
    // The following code is not necessary as it's already done in storyboard: in controller's
    // "Attributes" introspector / Layout, uncheck: Adjust Scroll View Insets.
    //
    // We can do this because the players table view happens to be the first subview.
    // See: http://stackoverflow.com/questions/19091737/
    //
    // self.automaticallyAdjustsScrollViewInsets = NO;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self mafia_refreshView];
}


#pragma mark - Public Methods


- (void)startGame:(MafiaGame *)game {
    NSAssert([game isReadyToStart], @"Game is not ready to start.");
    self.game = game;
    self.selectedPlayers = [NSMutableArray arrayWithCapacity:2];
    [self.game startGame];
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.game.playerList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MafiaJudgeDrivenGamePlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlayerCellID forIndexPath:indexPath];
    MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
    BOOL isSelected = [self.selectedPlayers containsObject:player];
    [cell setupWithPlayer:player isSelected:isSelected];
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


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UpdatePlayer"]) {
        // Find out the indexPath of the cell within which the button is tapped.
        // Go through the view hierarchy from the sender view, until UITableViewCell.
        UIView *currentView = sender;
        while (currentView != nil && ![currentView isKindOfClass:[UITableViewCell class]]) {
            currentView = currentView.superview;
        }
        NSAssert([currentView isKindOfClass:[UITableViewCell class]], @"Unable to find UITableViewCell from sender view.");
        UITableViewCell *cell = (UITableViewCell *) currentView;
        NSIndexPath *indexPath = [self.playersTableView indexPathForCell:cell];
        // Set the related player to destination view controller.
        MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
        MafiaUpdatePlayerController *controller = segue.destinationViewController;
        [controller loadPlayer:player];
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
        }
        // Continue to the next action.
        [self.game continueToNextAction];
        [self.selectedPlayers removeAllObjects];
    } else {
        // Cannot continue to next: wrong number of players selected.
        NSString *title = NSLocalizedString(@"Invalid Selections", nil);
        NSString *hintInSubtitle = [NSString stringWithFormat:
            NSLocalizedString(@"Select %@ player(s)", nil),
            [numberOfChoices string]];
        [TSMessage mafia_showErrorWithTitle:title subtitle:hintInSubtitle];
    }
    [self mafia_refreshView];
}


- (IBAction)resetButtonTapped:(id)sender {
    MafiaActionSheet *sheet = [MafiaActionSheet sheetWithTitle:NSLocalizedString(@"Are you sure to reset game?", nil)];
    [sheet setCancelButtonWithTitle:NSLocalizedString(@"No. Take me back.", nil) block:nil];
    [sheet setDestructiveButtonWithTitle:NSLocalizedString(@"Yes. Reset the game!", nil) block:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [sheet showInAppKeyWindow];
}


#pragma mark - Private Methods


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
        self.dayNightImageView.image = [UIImage imageNamed:@"action_in_day.png"];
        self.actionLabel.text = NSLocalizedString(@"Game Over", nil);
        self.promptLabel.text = nil;
        [TSMessage mafia_showGameResultWithWinner:self.game.winner];
    } else {
        // Game is still ongoing.
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Round %d", nil), self.game.round];
        self.nextBarButtonItem.enabled = YES;
        MafiaAction *currentAction = [self.game currentAction];
        self.dayNightImageView.image = [UIImage imageNamed:
            (currentAction.role != nil ? @"action_in_night.png" : @"action_in_day.png")];
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
