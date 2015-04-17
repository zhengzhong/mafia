//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAutonomicActionController.h"
#import "TSMessage+MafiaAdditions.h"

#import "MafiaGameplay.h"


static NSString *const kAutonomicActionHeaderCellID = @"AutonomicActionHeaderCell";
static NSString *const kTargetPlayerCellID = @"TargetPlayerCell";


// ------------------------------------------------------------------------------------------------
// Custom Cells
// ------------------------------------------------------------------------------------------------


@implementation MafiaAutonomicActionHeaderCell

- (void)setupWithAction:(MafiaAction *)action {
    self.actorImageView.image = [UIImage imageNamed:@"player.png"];  // TODO: player photo
    self.actionNameLabel.text = action.displayName;
    if (action.role != nil) {
        self.actionRoleLabel.text = action.role.displayName;
        self.actionRoleImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"role_%@.png", action.role.name]];
    } else {
        // TODO:
        self.actionRoleLabel.text = nil;
        self.actionRoleImageView.image = nil;
    }
    MafiaNumberRange *numberOfChoices = [action numberOfChoices];
    if (numberOfChoices.maxValue > 0) {
        self.actionPromptLabel.text = [NSString stringWithFormat:
            NSLocalizedString(@"Select %@ player(s)", nil),
            [numberOfChoices string]];
    } else {
        self.actionPromptLabel.text = NSLocalizedString(@"Click OK to continue", nil);
    }
}

@end


@implementation MafiaTargetPlayerCell

- (void)setupWithTargetPlayer:(MafiaPlayer *)player
                       ofRole:(MafiaRole *)role
                   selectable:(BOOL)selectable
                     selected:(BOOL)selected {
    self.imageView.image = [UIImage imageNamed:@"player.png"];  // TODO: player photo
    self.textLabel.text = player.displayName;
    self.textLabel.textColor = (selectable ? [UIColor blackColor] : [UIColor grayColor]);
    // TODO: 3-state check image!
    if (selected) {
        self.checkImageView.image = [UIImage imageNamed:@"player.png"];
    } else {
        self.checkImageView.image = nil;
    }
}

@end


// ------------------------------------------------------------------------------------------------
// MafiaAutonomicActionController
// ------------------------------------------------------------------------------------------------


@implementation MafiaAutonomicActionController


#pragma mark - Public Methods


- (void)setupWithGame:(MafiaGame *)game {
    self.game = game;
    self.selectedPlayers = [[NSMutableArray alloc] initWithCapacity:2];
    self.isActionCompleted = NO;
}


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    // Player must complete the action. There's no way back.
    self.navigationItem.hidesBackButton = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self mafia_refreshBarButtonItems];
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
        return [self mafia_tableView:tableView headerCellAtIndexPath:indexPath];
    } else {
        return [self mafia_tableView:tableView targetPlayerCellAtIndexPath:indexPath];
    }
}


- (UITableViewCell *)mafia_tableView:(UITableView *)tableView headerCellAtIndexPath:(NSIndexPath *)indexPath {
    MafiaAutonomicActionHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:kAutonomicActionHeaderCellID forIndexPath:indexPath];
    [cell setupWithAction:[self.game currentAction]];
    return cell;
}


- (UITableViewCell *)mafia_tableView:(UITableView *)tableView targetPlayerCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.game.playerList count]) {
        MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
        MafiaAction *action = [self.game currentAction];
        MafiaRole *role = action.role;
        BOOL selectable = [action isPlayerSelectable:player];
        BOOL selected = [self.selectedPlayers containsObject:player];
        MafiaTargetPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:kTargetPlayerCellID forIndexPath:indexPath];
        [cell setupWithTargetPlayer:player ofRole:role selectable:selectable selected:selected];
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


#pragma mark - Actions


- (IBAction)okButtonTapped:(id)sender {
    if (self.isActionCompleted) {
        NSLog(@"Action is already completed. OK button should not be tapped.");
        return;
    }
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
        MafiaInformation *information = [action endAction];
        NSString *hintInSubtitle = NSLocalizedString(@"Tap \"Done\" button on the top-left to continue.", nil);
        if (information != nil) {
            [TSMessage mafia_showMessageOfInformation:information subtitle:hintInSubtitle];
        } else {
            NSString *title = NSLocalizedString(@"Action Completed", nil);
            [TSMessage mafia_showMessageWithTitle:title subtitle:hintInSubtitle];
        }
        self.isActionCompleted = YES;
        [self mafia_refreshBarButtonItems];
    } else {
        // Cannot continue to next: wrong number of players selected.
        NSString *title = NSLocalizedString(@"Invalid Selections", nil);
        NSString *hintInSubtitle = [NSString stringWithFormat:
            NSLocalizedString(@"Select %@ player(s)", nil),
            [numberOfChoices string]];
        [TSMessage mafia_showErrorWithTitle:title subtitle:hintInSubtitle];
    }
    [self.tableView reloadData];
}


- (IBAction)doneButtonTapped:(id)sender {
    if (!self.isActionCompleted) {
        NSLog(@"Action is not completed. Done button should not be tapped.");
        return;
    }
    [self.delegate autonomicActionControllerDidCompleteAction:self];
}


#pragma mark - Private


- (void)mafia_refreshBarButtonItems {
    if (!self.isActionCompleted) {
        self.okBarButtonItem.enabled = YES;
        self.doneBarButtonItem.enabled = NO;
    } else {
        self.okBarButtonItem.enabled = NO;
        self.doneBarButtonItem.enabled = YES;
    }
}


@end
