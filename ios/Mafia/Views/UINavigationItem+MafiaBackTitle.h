//
//  Created by ZHENG Zhong on 2015-09-20.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem (MafiaBackTitle)

/// Clears the title of the left back bar button item in this navigation item. Each view controller
/// should call the following code in `viewDidLoad`:
///
///     [self.navigationItem mafia_clearBackTitle];
///
- (void)mafia_clearBackTitle;

@end
