//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaGameSetup;

@interface MafiaManagePlayersController : UITableViewController

@property (strong, nonatomic) MafiaGameSetup *gameSetup;
@property (strong, nonatomic) UIBarButtonItem *addBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *editBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *doneEditingBarButtonItem;

@end
