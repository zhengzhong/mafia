//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MafiaGameSetup;
@class MafiaRole;


@interface MafiaConfigureRoleController : UITableViewController

@property (strong, nonatomic) MafiaGameSetup *gameSetup;
@property (strong, nonatomic) MafiaRole *role;
@property (assign, nonatomic) NSInteger numberOfActors;

@end
