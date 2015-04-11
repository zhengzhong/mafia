//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAutonomicGameController.h"

#import "MafiaGameplay.h"


@interface MafiaAutonomicGameController () <UIActionSheetDelegate>

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
    return (section == 0 ? [self.game.playerList count] : 0);
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.game.playerList count]) {
        MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayerCell"];
        cell.imageView.image = [UIImage imageNamed:@"player.png"];  // TODO: player photo
        cell.textLabel.text = player.name;
        MafiaAction *action = [self.game currentAction];
        if (action != nil && action.player == player) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
    return nil;
}


#pragma mark - UITableViewDelegate


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.game.playerList count]) {
        MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
        MafiaAction *action = [self.game currentAction];
        if (action != nil && action.player == player) {
            return indexPath;
        }
    }
    return nil;
}


#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
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


@end
