//
//  Created by ZHENG Zhong on 2015-11-14.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaJudgeDrivenGameStoryboards.h"


static NSString *const kStoryboard = @"JudgeDrivenGame";
static NSString *const kJudgeDrivenGameController = @"JudgeDrivenGame";


@implementation MafiaJudgeDrivenGameStoryboards

+ (id)judgeDrivenGameController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboard bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:kJudgeDrivenGameController];
}

@end
