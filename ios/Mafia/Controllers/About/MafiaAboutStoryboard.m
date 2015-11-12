//
//  Created by ZHENG Zhong on 2015-11-12.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaAboutStoryboard.h"


static NSString *const kStoryboard = @"About";
static NSString *const kRootNavigationControllerID = @"AboutNavigationController";


@implementation MafiaAboutStoryboard

+ (id)rootNavigationController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboard bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:kRootNavigationControllerID];
    controller.tabBarItem.title = NSLocalizedString(@"About", nil);
    return controller;
}

@end
