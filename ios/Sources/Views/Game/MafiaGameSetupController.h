//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MafiaGameSetupPlayersController.h"
#import "MafiaGameSetupRoleController.h"


@class MafiaGameSetup;


@interface MafiaGameSetupController : UITableViewController <MafiaGameSetupPlayersControllerDelegate, MafiaGameSetupRoleControllerDelegate>

@property (readonly, retain, nonatomic) MafiaGameSetup *gameSetup;

+ (UIViewController *)controllerForTab;

- (id)initWithDefaultGameSetup;

- (void)twoHandedToggled:(id)sender;

- (void)roleSwitchToggled:(id)sender;

- (void)startGameTapped:(id)sender;

@end // MafiaGameSetupController

