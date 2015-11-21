//
//  Created by ZHENG Zhong on 2015-09-20.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "UINavigationItem+MafiaBackTitle.h"

@implementation UINavigationItem (MafiaBackTitle)

- (void)mafia_clearBackTitle {
    self.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                              style:UIBarButtonItemStylePlain
                                                             target:nil
                                                             action:nil];
}

@end
