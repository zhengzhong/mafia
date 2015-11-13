//
//  Created by ZHENG Zhong on 2015-11-13.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetupStoryboards.h"


static NSString *const kStoryboard = @"GameSetup";
static NSString *const kGameSetupControllerID = @"GameSetup";


@implementation MafiaGameSetupStoryboards

+ (id)gameSetupController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboard bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:kGameSetupControllerID];
}

@end
