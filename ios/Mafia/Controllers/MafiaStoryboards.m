//
//  Created by ZHENG Zhong on 2015-4-11.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaStoryboards.h"


static NSString *const kAutonomicGameStoryboard = @"AutonomicGame";

static NSString *const kAutonomicGameController = @"AutonomicGame";


@implementation MafiaStoryboards


+ (id)instantiateAutonomicGameController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kAutonomicGameStoryboard bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:kAutonomicGameController];
}


@end
