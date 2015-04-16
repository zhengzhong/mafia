//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameController.h"

#import "MafiaUpdatePlayerController.h"
#import "MafiaActionSheet.h"
#import "TSMessage+MafiaAdditions.h"

#import "MafiaGameplay.h"


@implementation MafiaGamePlayerCell


- (void)refreshWithPlayer:(MafiaPlayer *)player {
    // Refresh player information.
    self.avatarImageView.image = nil;  // TODO:
    self.nameLabel.text = player.displayName;
    self.roleLabel.text = player.role.displayName;
    NSString *roleImageName = nil;
    if (player.isDead) {
        roleImageName = @"role_dead.png";
    } else {
        roleImageName = [NSString stringWithFormat:@"role_%@.png", player.role.name];
    }
    self.roleImageView.image = [UIImage imageNamed:roleImageName];
    // Refresh status.
    NSUInteger statusIndex = 0;
    if (player.isMisdiagnosed) {
        UIImageView *imageView = self.statusImageViews[statusIndex];
        imageView.image = [UIImage imageNamed:@"is_misdiagnosed.png"];
        ++statusIndex;
    }
    if (player.isJustGuarded) {
        UIImageView *imageView = self.statusImageViews[statusIndex];
        imageView.image = [UIImage imageNamed:@"is_just_guarded.png"];
        ++statusIndex;
    }
    if (player.isUnguardable) {
        UIImageView *imageView = self.statusImageViews[statusIndex];
        imageView.image = [UIImage imageNamed:@"is_unguardable.png"];
        ++statusIndex;
    }
    if (player.isVoted) {
        UIImageView *imageView = self.statusImageViews[statusIndex];
        imageView.image = [UIImage imageNamed:@"is_voted.png"];
        ++statusIndex;
    }
    for (NSUInteger i = statusIndex; i < [self.statusImageViews count]; ++i) {
        UIImageView *imageView = self.statusImageViews[i];
        imageView.image = nil;
    }
    // Refresh tags.
    NSUInteger tagIndex = 0;
    for (MafiaRole *taggedByRole in player.currentRoleTags) {
        NSString *tagImageName = [NSString stringWithFormat:@"tag_%@.png", taggedByRole.name];
        UIImageView *imageView = self.tagImageViews[tagIndex];
        imageView.image = [UIImage imageNamed:tagImageName];
        ++tagIndex;
    }
    for (NSUInteger i = tagIndex; i < [self.tagImageViews count]; ++i) {
        UIImageView *imageView = self.tagImageViews[i];
        imageView.image = nil;
    }
}

@end


@implementation MafiaGameController


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
    MafiaGamePlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayerCell"];
    MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
    [cell refreshWithPlayer:player];
    return cell;
}


#pragma mark - UITableViewDelegate


// Note: Setting backgrund color of a cell must be done in this delegate method.
// See: http://developer.apple.com/library/ios/#documentation/uikit/reference/UITableViewCell_Class/Reference/Reference.html
// TODO: use a check mark to indicate a player is selected.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
    if ([self.selectedPlayers containsObject:player]) {
        cell.backgroundColor = [UIColor colorWithRed:0.87 green:0.94 blue:0.84 alpha:1.0];
    } else if (player.isDead) {
        cell.backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
}


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
        NSString *numberOfChoicesString = [numberOfChoices
            formattedStringWithSingleForm:NSLocalizedString(@"player", nil)
                               pluralForm:NSLocalizedString(@"players", nil)];
        NSString *hintInSubtitle = [NSString stringWithFormat:NSLocalizedString(@"You must select %@", nil), numberOfChoicesString];
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
        self.actionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Game over! %@ Wins!", nil), self.game.winner];
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
            NSString *numberOfChoicesString = [numberOfChoices
                formattedStringWithSingleForm:NSLocalizedString(@"player", nil)
                                   pluralForm:NSLocalizedString(@"players", nil)];
            self.promptLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Select %@", nil), numberOfChoicesString];
        } else if (currentAction.role != nil) {
            self.promptLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ not available", nil), currentAction.role];
        } else {
            self.promptLabel.text = NSLocalizedString(@"Continue to next", nil);
        }
    }
    [self.playersTableView reloadData];
}


@end
