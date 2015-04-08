//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameController.h"

#import "MafiaInformationController.h"
#import "MafiaUpdatePlayerController.h"

#import "MafiaGameplay.h"


@implementation MafiaGamePlayerCell


- (void)refreshWithPlayer:(MafiaPlayer *)player {
    // Refresh player information.
    self.avatarImageView.image = nil;  // TODO:
    self.nameLabel.text = player.name;
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
    for (MafiaRole *taggedByRole in player.tags) {
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


@interface MafiaGameController () <UIActionSheetDelegate, MafiaInformationControllerDelegate>

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


- (void)startWithGameSetup:(MafiaGameSetup *)gameSetup {
    self.game = [[MafiaGame alloc] initWithGameSetup:gameSetup];
    self.selectedPlayers = [NSMutableArray arrayWithCapacity:2];
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
    // Check if game is over.
    if (self.game.winner != nil) {
        return nil;
    }
    MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
    MafiaAction *currentAction = [self.game currentAction];
    if (!currentAction.isAssigned) {
        // Select player to assign role of current action: only unassigned player is selectable.
        return (player.isUnrevealed ? indexPath : nil);
    } else {
        return ([currentAction isPlayerSelectable:player] ? indexPath : nil);
    }
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


#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    } else if ([segue.identifier isEqualToString:@"ShowInformation"]) {
        MafiaInformationController *controller = segue.destinationViewController;
        controller.information = self.information;
        controller.delegate = self;
    }
}


#pragma mark - Actions


- (IBAction)nextButtonTapped:(id)sender {
    MafiaAction *currentAction = [self.game currentAction];
    MafiaNumberRange *numberOfChoices = [self mafia_numberOfChoicesForActon:currentAction];
    if ([numberOfChoices isNumberInRange:[self.selectedPlayers count]]) {
        // Assign role to player(s) or execute the current action.
        self.information = nil;
        if (!currentAction.isAssigned) {
            [currentAction assignRoleToPlayers:self.selectedPlayers];
        } else {
            [currentAction beginAction];
            if ([currentAction isExecutable]) {
                for (MafiaPlayer *player in self.selectedPlayers) {
                    [currentAction executeOnPlayer:player];
                }
            }
            self.information = [currentAction endAction];
            [self.game continueToNextAction];
        }
        // Clear the selected players.
        [self.selectedPlayers removeAllObjects];
        // Display information as necessary.
        if (self.information != nil) {
            [self performSegueWithIdentifier:@"ShowInformation" sender:self];
        }
    } else {
        // Cannot continue to next: wrong number of players selected.
        NSString *numberOfChoicesString = [numberOfChoices
            formattedStringWithSingleForm:NSLocalizedString(@"player", nil)
                               pluralForm:NSLocalizedString(@"players", nil)];
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"You must select %@", nil), numberOfChoicesString];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Messages", nil)
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    [self mafia_refreshView];
}


- (IBAction)resetButtonTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                 initWithTitle:NSLocalizedString(@"Are you sure to reset game?", nil)
                      delegate:self
             cancelButtonTitle:NSLocalizedString(@"No. Take me back.", nil)
        destructiveButtonTitle:NSLocalizedString(@"Yes. Reset the game!", nil)
             otherButtonTitles:nil];
    // See: http://stackoverflow.com/questions/4447563/last-button-of-actionsheet-does-not-get-clicked
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}


#pragma mark - MafiaInformationControllerDelegate


- (void)informationControllerDidComplete:(UIViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.information = nil;
}


#pragma mark - Private Methods


- (MafiaNumberRange *)mafia_numberOfChoicesForActon:(MafiaAction *)action {
    if (!action.isAssigned) {
        return [MafiaNumberRange numberRangeWithSingleValue:action.numberOfActors];
    } else if ([action isExecutable]) {
        return [action numberOfChoices];
    } else {
        return [MafiaNumberRange numberRangeWithSingleValue:0];
    }
}


- (void)mafia_refreshView {
    MafiaAction *currentAction = [self.game currentAction];
    self.dayNightImageView.image = [UIImage imageNamed:
        (currentAction.role != nil ? @"action_in_night.png" : @"action_in_day.png")];
    if (self.game.winner) {
        // Game over.
        self.title = NSLocalizedString(@"Game Over", nil);
        self.actionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Wins!", nil), self.game.winner];
        self.promptLabel.text = nil;
    } else {
        // Game ongoing.
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Round %d", nil), self.game.round];
        if (currentAction.isAssigned) {
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
        } else {
            self.actionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Assign %@", nil), currentAction.role];
            MafiaNumberRange *numberOfChoices = [self mafia_numberOfChoicesForActon:currentAction];
            NSString *numberOfChoicesString = [numberOfChoices
                formattedStringWithSingleForm:NSLocalizedString(@"player", nil)
                                   pluralForm:NSLocalizedString(@"players", nil)];
            self.promptLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Select %@", nil), numberOfChoicesString];
        }
    }
    [self.playersTableView reloadData];
}


@end
