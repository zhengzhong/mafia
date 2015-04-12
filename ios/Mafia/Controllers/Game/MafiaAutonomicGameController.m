//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAutonomicGameController.h"
#import "MafiaAutonomicActionController.h"

#import "MafiaGameplay.h"


static NSString *const kSegueStartAction = @"StartAction";


@interface MafiaAutonomicGameController () <UIActionSheetDelegate, MafiaAuthnomicActionControllerDelegate>

@end


@implementation MafiaAutonomicGameController


#pragma mark - Public Methods


- (void)startGame:(MafiaGame *)game {
    NSAssert(game.gameSetup.isAutonomic, @"This controller only accepts autonomic game.");
    self.game = game;
    [self.game startGame];
}


#pragma mark - Lifecycle


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell"];
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


#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // Action sheet is for resetting game.
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


#pragma mark - MafiaAuthnomicActionControllerDelegate


- (void)autonomicActionControllerDidCompleteAction:(UIViewController *)controller {
    // The current action is complete, and we are about to continue to the next action.
    [self.game continueToNextAction];
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Actions


- (IBAction)resetButtonTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                 initWithTitle:NSLocalizedString(@"Are you sure to reset game?", nil)
                      delegate:self
             cancelButtonTitle:NSLocalizedString(@"No. Take me back.", nil)
        destructiveButtonTitle:NSLocalizedString(@"Yes. Reset the game!", nil)
             otherButtonTitles:nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueStartAction]) {
        MafiaAutonomicActionController *controller = segue.destinationViewController;
        controller.delegate = self;
        [controller setupWithGame:self.game];
    }
}


@end
