//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaGameSetup;


@interface MafiaGameSetupController : UITableViewController

@property (readonly, strong, nonatomic) MafiaGameSetup *gameSetup;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *startButton;
@property (strong, nonatomic) IBOutlet UILabel *numberOfPlayersLabel;
@property (strong, nonatomic) IBOutlet UISwitch *twoHandedSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *autonomicSwitch;
@property (strong, nonatomic) IBOutlet UILabel *numberOfKillersLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberOfDetectivesLabel;
@property (strong, nonatomic) IBOutlet UISwitch *hasAssassinSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *hasGuardianSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *hasDoctorSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *hasTraitorSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *hasUndercoverSwitch;

- (IBAction)twoHandedToggled:(id)sender;

- (IBAction)autonomicToggled:(id)sender;

- (IBAction)hasAssassinToggled:(id)sender;

- (IBAction)hasGuardianToggled:(id)sender;

- (IBAction)hasDoctorToggled:(id)sender;

- (IBAction)hasTraitorToggled:(id)sender;

- (IBAction)hasUndercoverToggled:(id)sender;

@end
