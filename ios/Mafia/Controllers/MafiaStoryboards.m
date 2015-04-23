//
//  Created by ZHENG Zhong on 2015-4-11.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaStoryboards.h"


static NSString *const kGameSetupStoryboard = @"GameSetup";
static NSString *const kGameSetupController = @"GameSetup";

static NSString *const kJudgeDrivenGameStoryboard = @"JudgeDrivenGame";
static NSString *const kJudgeDrivenGameController = @"JudgeDrivenGame";

static NSString *const kAutonomicGameStoryboard = @"AutonomicGame";
static NSString *const kAutonomicGameController = @"AutonomicGame";


@implementation MafiaStoryboards


+ (id)instantiateGameSetupController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kGameSetupStoryboard bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:kGameSetupController];
}


+ (id)instantiateJudgeDrivenGameController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kJudgeDrivenGameStoryboard bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:kJudgeDrivenGameController];
}


+ (id)instantiateAutonomicGameController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kAutonomicGameStoryboard bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:kAutonomicGameController];
}


@end
