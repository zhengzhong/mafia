//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetupController.h"

#import "MafiaAssignRolesController.h"
#import "MafiaConfigureRoleController.h"
#import "MafiaManagePlayersController.h"

#import "MafiaGameplay.h"
#import "UIColor+MafiaAdditions.h"


static NSString *const kSegueManagePlayers = @"ManagePlayers";
static NSString *const kSegueConfigureNumberOfKillers = @"ConfigureNumberOfKillers";
static NSString *const kSegueConfigureNumberOfDetectives = @"ConfigureNumberOfDetectives";
static NSString *const kSegueAssignRoles = @"AssignRoles";


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
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self mafia_refreshUI];
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueManagePlayers]) {
        MafiaManagePlayersController *controller = segue.destinationViewController;
        controller.gameSetup = self.gameSetup;
    } else if ([segue.identifier isEqualToString:kSegueConfigureNumberOfKillers]) {
        MafiaConfigureRoleController *controller = segue.destinationViewController;
        controller.gameSetup = self.gameSetup;
        controller.role = [MafiaRole killer];
    } else if ([segue.identifier isEqualToString:kSegueConfigureNumberOfDetectives]) {
        MafiaConfigureRoleController *controller = segue.destinationViewController;
        controller.gameSetup = self.gameSetup;
        controller.role = [MafiaRole detective];
    } else if ([segue.identifier isEqualToString:kSegueAssignRoles]) {
        MafiaAssignRolesController *controller = segue.destinationViewController;
        [controller assignRolesRandomlyWithGameSetup:self.gameSetup];
    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:kSegueAssignRoles]) {
        return [self.gameSetup isValid];
    }
    return YES;
}


#pragma mark - Actions


- (IBAction)twoHandedToggled:(id)sender {
    self.gameSetup.isTwoHanded = ((UISwitch *)sender).on;
    [self mafia_refreshUI];
}


- (IBAction)autonomicToggled:(id)sender {
    self.gameSetup.isAutonomic = ((UISwitch *)sender).on;
    [self mafia_refreshUI];
}


- (IBAction)hasAssassinToggled:(id)sender {
    [self mafia_roleSwitch:sender toggledForRole:[MafiaRole assassin]];
}


- (IBAction)hasGuardianToggled:(id)sender {
    [self mafia_roleSwitch:sender toggledForRole:[MafiaRole guardian]];
}


- (IBAction)hasDoctorToggled:(id)sender {
    [self mafia_roleSwitch:sender toggledForRole:[MafiaRole doctor]];
}


- (IBAction)hasTraitorToggled:(id)sender {
    [self mafia_roleSwitch:sender toggledForRole:[MafiaRole traitor]];
}


- (IBAction)hasUndercoverToggled:(id)sender {
    [self mafia_roleSwitch:sender toggledForRole:[MafiaRole undercover]];
}


- (void)mafia_roleSwitch:(UISwitch *)roleSwitch toggledForRole:(MafiaRole *)role {
    NSInteger numberOfActors = (roleSwitch.on ? 1 : 0);
    [self.gameSetup setNumberOfActors:numberOfActors forRole:role];
    [self mafia_refreshUI];
}


#pragma mark - Private


- (void)mafia_refreshUI {
    self.startButton.enabled = [self.gameSetup isValid];
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"%@", @([self.gameSetup.playerNames count])];
    self.twoHandedSwitch.on = self.gameSetup.isTwoHanded;
    self.autonomicSwitch.on = self.gameSetup.isAutonomic;
    self.numberOfKillersLabel.text = [NSString stringWithFormat:@"%@", @([self.gameSetup numberOfActorsForRole:[MafiaRole killer]])];
    self.numberOfDetectivesLabel.text = [NSString stringWithFormat:@"%@", @([self.gameSetup numberOfActorsForRole:[MafiaRole detective]])];
    self.hasAssassinSwitch.on = ([self.gameSetup numberOfActorsForRole:[MafiaRole assassin]] > 0);
    self.hasGuardianSwitch.on = ([self.gameSetup numberOfActorsForRole:[MafiaRole guardian]] > 0);
    self.hasDoctorSwitch.on = ([self.gameSetup numberOfActorsForRole:[MafiaRole doctor]] > 0);
    self.hasTraitorSwitch.on = ([self.gameSetup numberOfActorsForRole:[MafiaRole traitor]] > 0);
    self.hasUndercoverSwitch.on = ([self.gameSetup numberOfActorsForRole:[MafiaRole undercover]] > 0);
}


@end
