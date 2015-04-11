//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAutonomicActionController.h"

#import "MafiaGameplay.h"


@implementation MafiaAutonomicActorCell

- (void)setupWithPlayer:(MafiaPlayer *)player numberOfChoices:(MafiaNumberRange *)numberOfChoices {
    self.avatarImageView.image = [UIImage imageNamed:@"player.png"];  // TODO: player photo
    self.nameLabel.text = player.name;
    self.roleLabel.text = player.role.displayName;
    self.roleImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"role_%@.png", player.role.name]];
    if (numberOfChoices.maxValue > 0) {
        NSString *numberOfChoicesString = [numberOfChoices
            formattedStringWithSingleForm:NSLocalizedString(@"player", nil)
                               pluralForm:NSLocalizedString(@"players", nil)];
        self.promptLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Select %@", nil), numberOfChoicesString];
    } else {
        self.promptLabel.text = NSLocalizedString(@"Click OK to continue", nil);
    }
}

@end


@implementation MafiaTargetPlayerCell

- (void)setupWithTargetPlayer:(MafiaPlayer *)player ofRole:(MafiaRole *)role selected:(BOOL)isSelected {
    self.imageView.image = [UIImage imageNamed:@"player.png"];  // TODO: player photo
    self.textLabel.text = player.name;
    // TODO: 3-state check image!
    if (isSelected) {
        self.checkImageView.image = [UIImage imageNamed:@"player.png"];
    } else {
        self.checkImageView.image = nil;
    }
}

@end


@implementation MafiaAutonomicActionController


#pragma mark - Public Methods


- (void)setupWithGame:(MafiaGame *)game {
    self.game = game;
    self.selectedPlayers = [[NSMutableArray alloc] initWithCapacity:2];
    self.information = nil;
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0 ? 1 : [self.game.playerList count]);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self mafia_tableView:tableView autonomicActorCellForRow:indexPath.row];
    } else {
        return [self mafia_tableView:tableView targetPlayerCellForRow:indexPath.row];
    }
}


- (UITableViewCell *)mafia_tableView:(UITableView *)tableView autonomicActorCellForRow:(NSInteger)row {
    MafiaAction *action = [self.game currentAction];
    MafiaPlayer *actor = action.player;
    MafiaNumberRange *numberOfChoices = [action numberOfChoices];
    MafiaAutonomicActorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AutonomicActorCell"];
    [cell setupWithPlayer:actor numberOfChoices:numberOfChoices];
    return cell;
}


- (UITableViewCell *)mafia_tableView:(UITableView *)tableView targetPlayerCellForRow:(NSInteger)row {
    if (row < [self.game.playerList count]) {
        MafiaPlayer *player = [self.game.playerList playerAtIndex:row];
        MafiaRole *role = [self.game currentAction].role;
        BOOL selected = [self.selectedPlayers containsObject:player];
        MafiaTargetPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TargetPlayerCell"];
        [cell setupWithTargetPlayer:player ofRole:role selected:selected];
        return cell;
    }
    return nil;
}


#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: use prototype cells to calculate height! Do NOT repeat what's declared in storyboard!
    if (indexPath.section == 0) {
        return 108.0;
    } else {
        return 44.0;
    }
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row < [self.game.playerList count]) {
        MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
        MafiaAction *action = [self.game currentAction];
        return ([action isPlayerSelectable:player] ? indexPath : nil);
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row < [self.game.playerList count]) {
        MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
        MafiaAction *action = [self.game currentAction];
        MafiaNumberRange *numberOfChoices = [action numberOfChoices];
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
        [self.tableView reloadData];
    }
}




#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


#pragma mark - Actions


- (IBAction)okButtonTapped:(id)sender {
    MafiaAction *action = [self.game currentAction];
    MafiaNumberRange *numberOfChoices = [action numberOfChoices];
    if ([numberOfChoices isNumberInRange:[self.selectedPlayers count]]) {
        // Execute the current action.
        [action beginAction];
        if ([action isExecutable]) {
            for (MafiaPlayer *player in self.selectedPlayers) {
                [action executeOnPlayer:player];
            }
        }
        self.information = [action endAction];
        // TODO: Display information if it's not nil.

        [self.delegate autonomicActionControllerDidCompleteAction:self];
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
    [self.tableView reloadData];
}


@end
