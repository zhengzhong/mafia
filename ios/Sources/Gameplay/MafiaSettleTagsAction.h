//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MafiaAction.h"


@interface MafiaSettleTagsAction : MafiaAction

- (id)initWithPlayerList:(MafiaPlayerList *)playerList;

+ (id)actionWithPlayerList:(MafiaPlayerList *)playerList;

- (MafiaInformation *)settleTags;

@end // MafiaSettleTagsAction

