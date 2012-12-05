//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MafiaGuideController : UITableViewController

@property (readonly, copy, nonatomic) NSArray *tableOfContents;

+ (UIViewController *)controllerForTab;

- (id)initWithTableOfContents;

@end // MafiaGuideController

