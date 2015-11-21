//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaGameSetup;


@interface MafiaGameSetupController : UITableViewController

@property (readonly, strong, nonatomic) MafiaGameSetup *gameSetup;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *startBarButtonItem;

@property (strong, nonatomic) IBOutlet UILabel *personsTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *twoHandedTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *autonomicTitleLabel;

@property (strong, nonatomic) IBOutlet UILabel *killersTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *detectivesTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *hasGuardianTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *hasDoctorTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *hasTraitorTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *hasAssassinTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *hasUndercoverTitleLabel;

@property (strong, nonatomic) IBOutlet UILabel *numberOfPersonsLabel;
@property (strong, nonatomic) IBOutlet UISwitch *twoHandedSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *autonomicSwitch;

@property (strong, nonatomic) IBOutlet UIButton *numberOfKillersButton;
@property (strong, nonatomic) IBOutlet UIButton *numberOfDetectivesButton;
@property (strong, nonatomic) IBOutlet UISwitch *hasGuardianSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *hasDoctorSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *hasTraitorSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *hasAssassinSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *hasUndercoverSwitch;

@property (strong, nonatomic) IBOutlet UIButton *saveGameSetupButton;
@property (strong, nonatomic) IBOutlet UIButton *loadGameSetupButton;

- (IBAction)twoHandedToggled:(id)sender;

- (IBAction)autonomicToggled:(id)sender;

- (IBAction)numberOfKillersButtonTapped:(id)sender;

- (IBAction)numberOfDetectivesButtonTapped:(id)sender;

- (IBAction)hasGuardianToggled:(id)sender;

- (IBAction)hasDoctorToggled:(id)sender;

- (IBAction)hasTraitorToggled:(id)sender;

- (IBAction)hasAssassinToggled:(id)sender;

- (IBAction)hasUndercoverToggled:(id)sender;

- (IBAction)startButtonTapped:(id)sender;

- (IBAction)saveButtonTapped:(id)sender;

+ (instancetype)controller;

@end
