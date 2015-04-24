//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAutonomicActionController.h"
#import "TSMessage+MafiaAdditions.h"
#import "UIImage+MafiaAdditions.h"

#import "MafiaGameplay.h"


static NSString *const kAvatarDefaultImageName = @"AvatarDefault";

static NSString *const kAutonomicActionHeaderCellID = @"AutonomicActionHeaderCell";
static NSString *const kTargetPlayerCellID = @"TargetPlayerCell";

static NSString *const kUnselectableImageName = @"Unselectable";
static NSString *const kSelectedImageName = @"Selected";
static NSString *const kUnselectedImageName = @"Unselected";

static NSString *const kTagImageName = @"Tag";


// ------------------------------------------------------------------------------------------------
// Custom Cells
// ------------------------------------------------------------------------------------------------


@implementation MafiaAutonomicActionHeaderCell

- (void)setupWithAction:(MafiaAction *)action {
    if (action.player != nil) {
        MafiaPerson *person = action.player.person;
        self.actorImageView.image = (person.avatarImage != nil ? person.avatarImage : [UIImage imageNamed:kAvatarDefaultImageName]);
    } else {
        self.actorImageView.image = [UIImage imageNamed:@"player.png"];  // TODO: action image
    }
    self.actorImageView.layer.cornerRadius = 5;
    self.actorImageView.clipsToBounds = YES;
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
                 isSelectable:(BOOL)isSelectable
                   isSelected:(BOOL)isSelected
                  wasSelected:(BOOL)wasSelected {
    UIImage *avatarImage = player.avatarImage;
    if (avatarImage == nil) {
        avatarImage = [UIImage imageNamed:kAvatarDefaultImageName];
    }
    if (player.isDead) {
        avatarImage = [avatarImage mafia_grayscaledImage];
    }
    self.avatarImageView.image = avatarImage;
    self.avatarImageView.layer.cornerRadius = 5;
    self.avatarImageView.clipsToBounds = YES;
    self.nameLabel.text = player.displayName;
    self.nameLabel.textColor = (isSelectable ? [UIColor blackColor] : [UIColor lightGrayColor]);
    if (!isSelectable) {
        self.checkImageView.image = [UIImage imageNamed:kUnselectableImageName];
    } else if (isSelected) {
        self.checkImageView.image = [UIImage imageNamed:kSelectedImageName];
    } else {
        self.checkImageView.image = [UIImage imageNamed:kUnselectedImageName];
    }
    if (wasSelected) {
        self.tagImageView.image = [UIImage imageNamed:kTagImageName];
    } else {
        self.tagImageView.image = nil;
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
        BOOL isSelectable = [action isPlayerSelectable:player];
        BOOL isSelected = [self.selectedPlayers containsObject:player];
        BOOL wasSelected = [player wasSelectedByRole:action.role];
        MafiaTargetPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:kTargetPlayerCellID forIndexPath:indexPath];
        [cell setupWithTargetPlayer:player
                             ofRole:role
                       isSelectable:isSelectable
                         isSelected:isSelected
                        wasSelected:wasSelected];
        return cell;
    }
    return nil;
}


#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: use prototype cells to calculate height! Do NOT repeat what's declared in storyboard!
    if (indexPath.section == 0) {
        return 132;
    } else {
        return 65;
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
