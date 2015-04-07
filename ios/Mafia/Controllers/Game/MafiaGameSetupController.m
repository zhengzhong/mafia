//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetupController.h"

#import "MafiaConfigureRoleController.h"
#import "MafiaGameController.h"
#import "MafiaSelectPlayersController.h"

#import "MafiaGameplay.h"
#import "UIColor+MafiaAdditions.h"


typedef NS_ENUM(NSInteger, kSectionConstants) {
    kPlayersSection = 0,
    kTwoHandedSection,
    kRolesSection,
    kNumberOfSections,
};


typedef NS_ENUM(NSInteger, kRoleRowConstants) {
    kNumberOfKillersRow = 0,
    kNumberOfDetectivesRow,
    kHasAssassinRow,
    kHasGuardianRow,
    kHasDoctorRow,
    kHasTraitorRow,
    kHasUndercoverRow,
    kNumberOfRoleRows,
};

static const NSInteger kSwitchTag = 1;


@interface MafiaGameSetupController ()

@property (readwrite, strong, nonatomic) MafiaGameSetup *gameSetup;

@end


@implementation MafiaGameSetupController


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameSetup = [[MafiaGameSetup alloc] init];
    NSArray *playerNames = @[ @"雯雯", @"狼尼", @"小何", @"大叔", @"青青", @"老妖", ];
    for (NSString *playerName in playerNames) {
        [self.gameSetup addPlayerName:playerName];
    }
    self.gameSetup.isTwoHanded = YES;
    self.title = NSLocalizedString(@"Game Setup", nil);
    self.startButton.enabled = [self.gameSetup isValid];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    self.startButton.enabled = [self.gameSetup isValid];
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberOfSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Only roles section contains multiple rows. Other sections have only 1 row each.
    return (section == kRolesSection ? kNumberOfRoleRows : 1);
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kPlayersSection: {
            UITableViewCell *cell = [self mafia_tableView:tableView
                                  cellWithNumberOfPlayers:[self.gameSetup.playerNames count]];
            cell.imageView.image = [UIImage imageNamed:@"players.png"];
            cell.textLabel.text = NSLocalizedString(@"Players", nil);
            if ([self.gameSetup.playerNames count] >= [self.gameSetup numberOfPlayersRequired]) {
                cell.detailTextLabel.textColor = [UIColor mafia_successColor];
            } else {
                cell.detailTextLabel.textColor = [UIColor mafia_dangerColor];
            }
            return cell;
        }
        case kTwoHandedSection: {
            UITableViewCell *cell = [self mafia_tableView:tableView
                                           cellWithSwitch:self.gameSetup.isTwoHanded
                                                   target:self
                                                   action:@selector(twoHandedToggled:)];
            cell.imageView.image = [UIImage imageNamed:@"two_handed.png"];
            cell.textLabel.text = NSLocalizedString(@"Two Handed", nil);
            return cell;
        }
        case kRolesSection: {
            switch (indexPath.row) {
                case kNumberOfKillersRow: {
                    UITableViewCell *cell = [self mafia_tableView:tableView
                                                   cellWithNumber:self.gameSetup.numberOfKillers];
                    cell.imageView.image = [UIImage imageNamed:@"role_killer.png"];
                    cell.textLabel.text = NSLocalizedString(@"Number of Killers", nil);
                    return cell;
                }
                case kNumberOfDetectivesRow: {
                    UITableViewCell *cell = [self mafia_tableView:tableView
                                                   cellWithNumber:self.gameSetup.numberOfDetectives];
                    cell.imageView.image = [UIImage imageNamed:@"role_detective.png"];
                    cell.textLabel.text = NSLocalizedString(@"Number of Detectives", nil);
                    return cell;
                }
                case kHasAssassinRow: {
                    UITableViewCell *cell = [self mafia_tableView:tableView
                                                   cellWithSwitch:self.gameSetup.hasAssassin
                                                           target:self
                                                           action:@selector(hasAssassinToggled:)];
                    cell.imageView.image = [UIImage imageNamed:@"role_assassin.png"];
                    cell.textLabel.text = NSLocalizedString(@"Has Assassin", nil);
                    return cell;
                }
                case kHasGuardianRow: {
                    UITableViewCell *cell = [self mafia_tableView:tableView
                                                   cellWithSwitch:self.gameSetup.hasGuardian
                                                           target:self
                                                           action:@selector(hasGuardianToggled:)];
                    cell.imageView.image = [UIImage imageNamed:@"role_guardian.png"];
                    cell.textLabel.text = NSLocalizedString(@"Has Guardian", nil);
                    return cell;
                }
                case kHasDoctorRow: {
                    UITableViewCell *cell = [self mafia_tableView:tableView
                                                   cellWithSwitch:self.gameSetup.hasDoctor
                                                           target:self
                                                           action:@selector(hasDoctorToggled:)
                                             ];
                    cell.imageView.image = [UIImage imageNamed:@"role_doctor.png"];
                    cell.textLabel.text = NSLocalizedString(@"Has Doctor", nil);
                    return cell;
                }
                case kHasTraitorRow: {
                    UITableViewCell *cell = [self mafia_tableView:tableView
                                                   cellWithSwitch:self.gameSetup.hasTraitor
                                                           target:self
                                                           action:@selector(hasTraitorToggled:)];
                    cell.imageView.image = [UIImage imageNamed:@"role_traitor.png"];
                    cell.textLabel.text = NSLocalizedString(@"Has Traitor", nil);
                    return cell;
                }
                case kHasUndercoverRow: {
                    UITableViewCell *cell = [self mafia_tableView:tableView
                                                   cellWithSwitch:self.gameSetup.hasUndercover
                                                           target:self
                                                           action:@selector(hasUndercoverToggled:)];
                    cell.imageView.image = [UIImage imageNamed:@"role_undercover.png"];
                    cell.textLabel.text = NSLocalizedString(@"Has Undercover", nil);
                    return cell;
                }
                default: {
                    return nil;
                }
            }
        }
        default:
        {
            return nil;
        }
    }
}


#pragma mark - UITableViewDelegate


- (NSIndexPath *)tableView:(UITableView *)tableView
    willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kPlayersSection) {
        return indexPath;
    }
    if (indexPath.section == kRolesSection) {
        if (indexPath.row == kNumberOfKillersRow || indexPath.row == kNumberOfDetectivesRow) {
            return indexPath;
        }
    }
    // All the other rows are not selectable.
    return nil;
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectPlayers"]) {
        MafiaSelectPlayersController *controller = segue.destinationViewController;
        controller.gameSetup = self.gameSetup;
    } else if ([segue.identifier isEqualToString:@"ConfigureRole"]) {
        MafiaConfigureRoleController *controller = segue.destinationViewController;
        controller.gameSetup = self.gameSetup;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath.section == kRolesSection) {
            if (indexPath.row == kNumberOfKillersRow) {
                controller.role = [MafiaRole killer];
            } else if (indexPath.row == kNumberOfDetectivesRow) {
                controller.role = [MafiaRole detective];
            }
        }
    } else if ([segue.identifier isEqualToString:@"StartGame"]) {
        MafiaGameController *controller = segue.destinationViewController;
        [controller startWithGameSetup:self.gameSetup];
    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"StartGame"]) {
        return [self.gameSetup isValid];
    }
    return YES;
}


#pragma mark - Callbacks


- (void)twoHandedToggled:(id)sender {
    self.gameSetup.isTwoHanded = ((UISwitch *)sender).on;
    self.startButton.enabled = [self.gameSetup isValid];
}


- (void)hasAssassinToggled:(id)sender {
    self.gameSetup.hasAssassin = ((UISwitch *) sender).on;
    self.startButton.enabled = [self.gameSetup isValid];
}


- (void)hasGuardianToggled:(id)sender {
    self.gameSetup.hasGuardian = ((UISwitch *) sender).on;
    self.startButton.enabled = [self.gameSetup isValid];
}


- (void)hasDoctorToggled:(id)sender {
    self.gameSetup.hasDoctor = ((UISwitch *) sender).on;
    self.startButton.enabled = [self.gameSetup isValid];
}


- (void)hasTraitorToggled:(id)sender {
    self.gameSetup.hasTraitor = ((UISwitch *) sender).on;
    self.startButton.enabled = [self.gameSetup isValid];
}


- (void)hasUndercoverToggled:(id)sender {
    self.gameSetup.hasUndercover = ((UISwitch *) sender).on;
    self.startButton.enabled = [self.gameSetup isValid];
}


#pragma mark - Private


- (UITableViewCell *)mafia_tableView:(UITableView *)tableView
             cellWithNumberOfPlayers:(NSInteger)numberOfPlayers {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellOfPlayers"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", @(numberOfPlayers)];
    return cell;
}


- (UITableViewCell *)mafia_tableView:(UITableView *)tableView
                      cellWithNumber:(NSInteger)number {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellWithNumber"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", @(number)];
    return cell;
}


- (UITableViewCell *)mafia_tableView:(UITableView *)tableView
                      cellWithSwitch:(BOOL)on
                              target:(id)target
                              action:(SEL)action {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellWithSwitch"];
    UISwitch *switchInCell = (UISwitch *)[cell.contentView viewWithTag:kSwitchTag];
    switchInCell.on = on;
    [switchInCell addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return cell;
}


@end
