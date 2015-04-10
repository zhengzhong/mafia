//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MafiaAction.h"

/*!
 * This action is executed by all alive players during the day. It is executed on the voted player.
 */
@interface MafiaVoteAndLynchAction : MafiaAction

+ (instancetype)actionWithPlayerList:(MafiaPlayerList *)playerList;

- (MafiaInformation *)settleVoteAndLynch;

@end
