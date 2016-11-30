//
//  Created by ZHENG Zhong on 2016-11-30.
//  Copyright (c) 2016 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MafiaAction.h"


/// This is the first action to execute when night begins. This action has no role or player.
@interface MafiaNewRoundAction : MafiaAction

+ (instancetype)actionWithPlayerList:(MafiaPlayerList *)playerList;

@end
