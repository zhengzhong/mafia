//
//  Created by ZHENG Zhong on 2015-11-12.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameStoryboard.h"


static NSString *const kStoryboard = @"Game";
static NSString *const kRootNavigationControllerID = @"GameNavigationController";


@implementation MafiaGameStoryboard

+ (id)rootNavigationController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboard bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:kRootNavigationControllerID];
    controller.tabBarItem.title = NSLocalizedString(@"Game", nil);
    return controller;
}

@end
