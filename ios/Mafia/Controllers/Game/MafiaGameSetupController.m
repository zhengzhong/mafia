//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetupController.h"

#import "MafiaAssignRolesController.h"
#import "MafiaConfigureRoleController.h"
#import "MafiaLoadGameSetupController.h"
#import "MafiaManagePlayersController.h"
#import "MafiaAlertView.h"
#import "TSMessage+MafiaAdditions.h"
#import "UIColor+MafiaAdditions.h"

#import "MafiaGameplay.h"


static NSString *const kSegueManagePlayers = @"ManagePlayers";
static NSString *const kSegueConfigureNumberOfKillers = @"ConfigureNumberOfKillers";
static NSString *const kSegueConfigureNumberOfDetectives = @"ConfigureNumberOfDetectives";
static NSString *const kSegueLoadGameSetup = @"LoadGameSetup";
static NSString *const kSegueAssignRoles = @"AssignRoles";

static NSString *const kAvatarWenwenImageName = @"AvatarWenwen";
static NSString *const kAvatarXiaoheImageName = @"AvatarXiaohe";
static NSString *const kAvatarLangniImageName = @"AvatarLangni";
static NSString *const kAvatarDashuImageName = @"AvatarDashu";
static NSString *const kAvatarQingqingImageName = @"AvatarQingqing";
static NSString *const kAvatarLaoyaoImageName = @"AvatarLaoyao";


@interface MafiaGameSetupController () <MafiaLoadGameSetupControllerDelegate>

@property (readwrite, strong, nonatomic) MafiaGameSetup *gameSetup;

@end


@implementation MafiaGameSetupController


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameSetup = [[MafiaGameSetup alloc] init];
    NSArray *persons = @[
        [MafiaPerson personWithName:@"雯雯" avatarImage:[UIImage imageNamed:kAvatarWenwenImageName]],
        [MafiaPerson personWithName:@"小何" avatarImage:[UIImage imageNamed:kAvatarXiaoheImageName]],
        [MafiaPerson personWithName:@"狼尼" avatarImage:[UIImage imageNamed:kAvatarLangniImageName]],
        [MafiaPerson personWithName:@"大叔" avatarImage:[UIImage imageNamed:kAvatarDashuImageName]],
        [MafiaPerson personWithName:@"青青" avatarImage:[UIImage imageNamed:kAvatarQingqingImageName]],
        [MafiaPerson personWithName:@"老妖" avatarImage:[UIImage imageNamed:kAvatarLaoyaoImageName]],
    ];
    for (MafiaPerson *person in persons) {
        [self.gameSetup addPerson:person];
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
    } else if ([segue.identifier isEqualToString:kSegueLoadGameSetup]) {
        UINavigationController *navigationController = segue.destinationViewController;
        MafiaLoadGameSetupController *controller = navigationController.viewControllers[0];
        controller.delegate = self;
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


#pragma mark - Save / Load Actions


- (IBAction)saveButtonTapped:(id)sender {
    MafiaAlertView *gameSetupNameAlertView = [MafiaAlertView
                                              alertWithTitle:NSLocalizedString(@"Save Game Setup", nil)
                                              message:NSLocalizedString(@"Please specify the game setup name", nil)
                                              style:UIAlertViewStylePlainTextInput];
    [gameSetupNameAlertView setCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil) block:nil];
    [gameSetupNameAlertView
     setConfirmButtonWithTitle:NSLocalizedString(@"Save", nil)
     block:^(MafiaAlertView *alertView) {
         NSString *name = alertView.plainTextField.text;
         name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
         // TODO: show error details maybe?
         if ([name length] > 0) {
             BOOL success = [self.gameSetup saveGameSetupWithName:name];
             if (success) {
                 [TSMessage mafia_showSuccessWithTitle:NSLocalizedString(@"Game setup saved successfully!", nil)
                                              subtitle:nil];
             } else {
                 [TSMessage mafia_showErrorWithTitle:NSLocalizedString(@"Fail to save game setup.", nil)
                                              subtitle:nil];
             }
         } else {
             [TSMessage mafia_showErrorWithTitle:NSLocalizedString(@"Invalid game setup name.", nil)
                                        subtitle:nil];
         }
     }];
    [gameSetupNameAlertView show];
}


#pragma mark - MafiaLoadGameSetupControllerDelegate


- (void)loadGameSetupController:(MafiaLoadGameSetupController *)controller
               didLoadGameSetup:(MafiaGameSetup *)gameSetup {
    self.gameSetup = gameSetup;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self mafia_refreshUI];
}


- (void)loadGameSetupControllerDidCancel:(MafiaLoadGameSetupController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Private


- (void)mafia_refreshUI {
    self.startButton.enabled = [self.gameSetup isValid];
    self.numberOfPersonsLabel.text = [NSString stringWithFormat:@"%@", @([self.gameSetup.persons count])];
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
