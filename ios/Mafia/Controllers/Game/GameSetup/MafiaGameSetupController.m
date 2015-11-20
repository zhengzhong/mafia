//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetupController.h"

#import "MafiaAssignRolesController.h"
#import "MafiaConfigureRoleController.h"
#import "MafiaLoadGameSetupController.h"
#import "MafiaManagePlayersController.h"

#import "MafiaAssets.h"
#import "MafiaGameplay.h"

#import "TSMessage+MafiaAdditions.h"


static NSString *const kStoryboard = @"GameSetup";
static NSString *const kControllerID = @"GameSetup";


static NSString *const kSegueManagePlayers = @"ManagePlayers";
static NSString *const kSegueConfigureNumberOfKillers = @"ConfigureNumberOfKillers";
static NSString *const kSegueConfigureNumberOfDetectives = @"ConfigureNumberOfDetectives";
static NSString *const kSegueLoadGameSetup = @"LoadGameSetup";
static NSString *const kSegueAssignRoles = @"AssignRoles";


@interface MafiaGameSetupController () <MafiaLoadGameSetupControllerDelegate>

@property (readwrite, strong, nonatomic) MafiaGameSetup *gameSetup;

@end


@implementation MafiaGameSetupController


#pragma mark - Storyboard


+ (instancetype)controller {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboard bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:kControllerID];
}


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameSetup = [MafiaGameSetup loadRecent];
    if (self.gameSetup == nil) {
        self.gameSetup = [[MafiaGameSetup alloc] init];
        NSArray *persons = @[
            [MafiaPerson personWithName:@"雯雯" avatarImage:[MafiaAssets imageOfAvatar:MafiaAvatarWenwen]],
            [MafiaPerson personWithName:@"小何" avatarImage:[MafiaAssets imageOfAvatar:MafiaAvatarXiaohe]],
            [MafiaPerson personWithName:@"狼尼" avatarImage:[MafiaAssets imageOfAvatar:MafiaAvatarLangni]],
            [MafiaPerson personWithName:@"大叔" avatarImage:[MafiaAssets imageOfAvatar:MafiaAvatarDashu]],
            [MafiaPerson personWithName:@"青青" avatarImage:[MafiaAssets imageOfAvatar:MafiaAvatarQingqing]],
            [MafiaPerson personWithName:@"老妖" avatarImage:[MafiaAssets imageOfAvatar:MafiaAvatarLaoyao]],
            [MafiaPerson personWithName:@"郑导" avatarImage:[MafiaAssets imageOfAvatar:MafiaAvatarZhengdao]],
        ];
        for (MafiaPerson *person in persons) {
            [self.gameSetup addPerson:person];
        }
        self.gameSetup.isTwoHanded = YES;
    }
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
        return;
    }

    if ([segue.identifier isEqualToString:kSegueConfigureNumberOfKillers]) {
        MafiaConfigureRoleController *controller = segue.destinationViewController;
        controller.gameSetup = self.gameSetup;
        controller.role = [MafiaRole killer];
        return;
    }

    if ([segue.identifier isEqualToString:kSegueConfigureNumberOfDetectives]) {
        MafiaConfigureRoleController *controller = segue.destinationViewController;
        controller.gameSetup = self.gameSetup;
        controller.role = [MafiaRole detective];
        return;
    }

    if ([segue.identifier isEqualToString:kSegueLoadGameSetup]) {
        UINavigationController *navigationController = segue.destinationViewController;
        MafiaLoadGameSetupController *controller = navigationController.viewControllers[0];
        controller.delegate = self;
        return;
    }

    if ([segue.identifier isEqualToString:kSegueAssignRoles]) {
        [self.gameSetup saveAsRecent];
        MafiaAssignRolesController *controller = segue.destinationViewController;
        [controller assignRolesRandomlyWithGameSetup:self.gameSetup];
        return;
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


#pragma mark - Save / Load


- (IBAction)saveButtonTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(@"Save Game Setup", nil)
                         message:nil
                  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Game setup name", nil);
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];

    void (^saveGameSetupBlock)(UIAlertAction *) = ^(UIAlertAction *action) {
        NSString *name = alertController.textFields[0].text;
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([name length] == 0) {
            [TSMessage mafia_showErrorWithTitle:NSLocalizedString(@"Invalid game setup name.", nil)
                                       subtitle:nil];
            return;
        }

        self.gameSetup.date = [NSDate date];
        BOOL success = [self.gameSetup saveWithName:name];
        if (success) {
            [TSMessage mafia_showSuccessWithTitle:NSLocalizedString(@"Game setup saved successfully!", nil)
                                         subtitle:nil];
        } else {
            [TSMessage mafia_showErrorWithTitle:NSLocalizedString(@"Fail to save game setup.", nil)
                                       subtitle:nil];
        }
    };
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:saveGameSetupBlock];
    [alertController addAction:okAction];

    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - MafiaLoadGameSetupControllerDelegate


- (void)loadGameSetupController:(MafiaLoadGameSetupController *)controller
               didLoadGameSetup:(MafiaGameSetup *)gameSetup {
    self.gameSetup = gameSetup;
    [self dismissViewControllerAnimated:YES completion:^{
        [TSMessage mafia_showSuccessWithTitle:NSLocalizedString(@"Game setup loaded successfully!", nil)
                                     subtitle:nil];
        [self mafia_refreshUI];
    }];
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
