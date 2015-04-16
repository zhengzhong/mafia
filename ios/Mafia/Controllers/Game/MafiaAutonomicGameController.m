//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAutonomicGameController.h"
#import "MafiaAutonomicActionController.h"
#import "MafiaActionSheet.h"
#import "TSMessage+MafiaAdditions.h"

#import "MafiaGameplay.h"


static NSString *const kSegueStartAction = @"StartAction";

static NSString *const kActionCellID = @"ActionCell";


@interface MafiaAutonomicGameController () <MafiaAuthnomicActionControllerDelegate>

@end


@implementation MafiaAutonomicGameController


#pragma mark - Public Methods


- (void)startGame:(MafiaGame *)game {
    NSAssert(game.gameSetup.isAutonomic, @"This controller only accepts autonomic game.");
    self.game = game;
    [self.game startGame];
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0 ? [self.game.actions count] : 0);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row < [self.game.actions count]) {
        MafiaAction *action = self.game.actions[indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kActionCellID forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"player.png"];  // TODO: actor photo
        cell.textLabel.text = action.displayName;
        if (action == [self.game currentAction]) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.textLabel.textColor = [UIColor grayColor];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
    return nil;
}


#pragma mark - UITableViewDelegate


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row < [self.game.actions count]) {
        MafiaAction *action = self.game.actions[indexPath.row];
        if (action == [self.game currentAction]) {
            return indexPath;
        }
    }
    return nil;
}


#pragma mark - MafiaAuthnomicActionControllerDelegate


- (void)autonomicActionControllerDidCompleteAction:(UIViewController *)controller {
    // The current action is complete, and we are about to continue to the next action.
    [self.game continueToNextAction];
    [self.navigationController popViewControllerAnimated:YES];
    [self mafia_refreshUI];
}


#pragma mark - Actions


- (IBAction)resetButtonTapped:(id)sender {
    MafiaActionSheet *sheet = [MafiaActionSheet sheetWithTitle:NSLocalizedString(@"Are you sure to reset game?", nil)];
    [sheet setCancelButtonWithTitle:NSLocalizedString(@"No. Take me back.", nil) block:nil];
    [sheet setDestructiveButtonWithTitle:NSLocalizedString(@"Yes. Reset the game!", nil) block:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [sheet showInAppKeyWindow];
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueStartAction]) {
        MafiaAutonomicActionController *controller = segue.destinationViewController;
        controller.delegate = self;
        [controller setupWithGame:self.game];
    }
}


#pragma mark - Private Methods


- (void)mafia_refreshUI {
    if (self.game.winner != MafiaWinnerUnknown) {
        self.title = NSLocalizedString(@"Game Over", nil);
        [TSMessage mafia_showGameResultWithWinner:self.game.winner];
    }
    [self.tableView reloadData];
}


@end
