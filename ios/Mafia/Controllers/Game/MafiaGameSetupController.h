//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaGameSetup;


@interface MafiaGameSetupController : UITableViewController

@property (readonly, strong, nonatomic) MafiaGameSetup *gameSetup;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *startButton;

@end
