//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MafiaAction.h"


/*!
 * This action is executed at dawn, when all the roles have executed their actions at night.
 */
@interface MafiaSettleTagsAction : MafiaAction

+ (instancetype)actionWithPlayerList:(MafiaPlayerList *)playerList;

- (instancetype)initWithPlayerList:(MafiaPlayerList *)playerList
    NS_DESIGNATED_INITIALIZER;

- (MafiaInformation *)settleTags;

@end  // MafiaSettleTagsAction