//
//  Created by ZHENG Zhong on 2015-04-22.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameController.h"
#import "MafiaGameSetupController.h"
#import "MafiaStoryboards.h"


@implementation MafiaGameController


- (IBAction)createNewGameSetupButtonTapped:(id)sender {
    MafiaGameSetupController *controller = [MafiaStoryboards instantiateGameSetupController];
    [self.navigationController pushViewController:controller animated:YES];
}


@end
