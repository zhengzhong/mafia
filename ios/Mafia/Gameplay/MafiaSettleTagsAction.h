//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MafiaAction.h"


/*!
 * This action is executed at dawn, when all the actors have executed their actions at night.
 * This action has no role or player. It has no actors, and cannot be executed on any player.
 * So, only `beginAction` and `endAction` will be called, but not `executeOnPlayer:`.
 */
@interface MafiaSettleTagsAction : MafiaAction

+ (instancetype)actionWithPlayerList:(MafiaPlayerList *)playerList;

/*!
 * Settles all tags and returns the result as an information.
 */
- (MafiaInformation *)settleTags;

@end
