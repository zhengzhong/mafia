//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetupController.h"

#import "MafiaAssignRolesController.h"
#import "MafiaLoadGameSetupController.h"
#import "MafiaManagePlayersController.h"

#import "MafiaAssets.h"
#import "MafiaGameplay.h"

#import "TSMessage+MafiaAdditions.h"
#import "UIView+MafiaAdditions.h"


static NSString *const kStoryboard = @"GameSetup";
static NSString *const kControllerID = @"GameSetup";


static NSString *const kSegueManagePlayers = @"ManagePlayers";
static NSString *const kSegueLoadGameSetup = @"LoadGameSetup";
static NSString *const kSegueStartToAssignRoles = @"StartToAssignRoles";


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
    self.title = NSLocalizedString(@"Game Setup", nil);

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

    self.startBarButtonItem.title = NSLocalizedString(@"Start", nil);

    self.personsTitleLabel.text = nil;  // Dynamic content.
    self.twoHandedTitleLabel.text = NSLocalizedString(@"Two-Handed Mode", nil);
    self.autonomicTitleLabel.text = NSLocalizedString(@"Autonomic Mode", nil);

    self.killersTitleLabel.text = NSLocalizedString(@"Killers", nil);
    self.detectivesTitleLabel.text = NSLocalizedString(@"Detectives", nil);
    self.hasGuardianTitleLabel.text = NSLocalizedString(@"Has Guardian?", nil);
    self.hasDoctorTitleLabel.text = NSLocalizedString(@"Has Doctor?", nil);
    self.hasTraitorTitleLabel.text = NSLocalizedString(@"Has Traitor?", nil);
    self.hasAssassinTitleLabel.text = NSLocalizedString(@"Has Assassin?", nil);
    self.hasUndercoverTitleLabel.text = NSLocalizedString(@"Has Undercover?", nil);

    [self.numberOfKillersButton mafia_makeRoundCornersWithBorder:YES];
    [self.numberOfDetectivesButton mafia_makeRoundCornersWithBorder:YES];

    [self.saveGameSetupButton setTitle:NSLocalizedString(@"Save Game Setup", nil) forState:UIControlStateNormal];
    [self.loadGameSetupButton setTitle:NSLocalizedString(@"Load Game Setup", nil) forState:UIControlStateNormal];
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
    if ([segue.identifier isEqualToString:kSegueLoadGameSetup]) {
        UINavigationController *navigationController = segue.destinationViewController;
        MafiaLoadGameSetupController *controller = navigationController.viewControllers[0];
        controller.delegate = self;
        return;
    }
    if ([segue.identifier isEqualToString:kSegueStartToAssignRoles]) {
        [self.gameSetup saveAsRecent];
        MafiaAssignRolesController *controller = segue.destinationViewController;
        [controller assignRolesRandomlyWithGameSetup:self.gameSetup];
        return;
    }
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


- (IBAction)numberOfKillersButtonTapped:(id)sender {
    [self mafia_updateNumberOfActorsForRole:[MafiaRole killer]];
    [self mafia_refreshUI];
}


- (IBAction)numberOfDetectivesButtonTapped:(id)sender {
    [self mafia_updateNumberOfActorsForRole:[MafiaRole detective]];
    [self mafia_refreshUI];
}


- (void)mafia_updateNumberOfActorsForRole:(MafiaRole *)role {
    static const NSInteger kMaxNumberOfActors = 4;
    NSInteger numberOfActors = [self.gameSetup numberOfActorsForRole:role] + 1;
    if (numberOfActors > kMaxNumberOfActors) {
        numberOfActors = 1;
    }
    [self.gameSetup setNumberOfActors:numberOfActors forRole:role];
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


- (IBAction)hasAssassinToggled:(id)sender {
    [self mafia_roleSwitch:sender toggledForRole:[MafiaRole assassin]];
}


- (IBAction)hasUndercoverToggled:(id)sender {
    [self mafia_roleSwitch:sender toggledForRole:[MafiaRole undercover]];
}


- (void)mafia_roleSwitch:(UISwitch *)roleSwitch toggledForRole:(MafiaRole *)role {
    NSInteger numberOfActors = (roleSwitch.on ? 1 : 0);
    [self.gameSetup setNumberOfActors:numberOfActors forRole:role];
    [self mafia_refreshUI];
}


- (IBAction)startButtonTapped:(id)sender {
    if ([self.gameSetup isValid]) {
        [self performSegueWithIdentifier:kSegueStartToAssignRoles sender:self];
    } else {
        NSInteger numberOfPersonsRequired = [self.gameSetup numberOfPersonsRequired];
        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"This game setup requires at least %@ persons.", nil), @(numberOfPersonsRequired)];
        [TSMessage mafia_showErrorWithTitle:title subtitle:nil];
    }
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
    NSMutableArray *personNames = [[NSMutableArray alloc] initWithCapacity:3];
    for (MafiaPerson *person in self.gameSetup.persons) {
        if ([personNames count] < 2) {
            [personNames addObject:person.name];
        } else {
            [personNames addObject:@"..."];
            break;
        }
    }
    self.personsTitleLabel.text = [personNames componentsJoinedByString:@", "];

    self.numberOfPersonsLabel.text = [NSString stringWithFormat:@"%@", @([self.gameSetup.persons count])];
    self.twoHandedSwitch.on = self.gameSetup.isTwoHanded;
    self.autonomicSwitch.on = self.gameSetup.isAutonomic;

    NSInteger numberOfKillers = [self.gameSetup numberOfActorsForRole:[MafiaRole killer]];
    [self.numberOfKillersButton setTitle:[NSString stringWithFormat:@"x %@", @(numberOfKillers)]
                                forState:UIControlStateNormal];

    NSInteger numberOfDetectives = [self.gameSetup numberOfActorsForRole:[MafiaRole detective]];
    [self.numberOfDetectivesButton setTitle:[NSString stringWithFormat:@"x %@", @(numberOfDetectives)]
                                   forState:UIControlStateNormal];

    self.hasGuardianSwitch.on = ([self.gameSetup numberOfActorsForRole:[MafiaRole guardian]] > 0);
    self.hasDoctorSwitch.on = ([self.gameSetup numberOfActorsForRole:[MafiaRole doctor]] > 0);
    self.hasTraitorSwitch.on = ([self.gameSetup numberOfActorsForRole:[MafiaRole traitor]] > 0);
    self.hasAssassinSwitch.on = ([self.gameSetup numberOfActorsForRole:[MafiaRole assassin]] > 0);
    self.hasUndercoverSwitch.on = ([self.gameSetup numberOfActorsForRole:[MafiaRole undercover]] > 0);
}


@end
