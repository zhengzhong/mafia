//
//  Created by ZHENG Zhong on 2016-11-30.
//  Copyright (c) 2016 ZHENG Zhong. All rights reserved.
//

#import "MafiaNewRoundAction.h"
#import "MafiaInformation.h"
#import "MafiaNumberRange.h"
#import "MafiaPlayer.h"
#import "MafiaPlayerList.h"
#import "MafiaRole.h"


@implementation MafiaNewRoundAction


#pragma mark - Factory Method and Initializer


+ (instancetype)actionWithPlayerList:(MafiaPlayerList *)playerList {
    return [[self alloc] initWithRole:nil player:nil playerList:playerList];
}


- (instancetype)initWithRole:(MafiaRole *)role
                      player:(MafiaPlayer *)player
                  playerList:(MafiaPlayerList *)playerList {
    // Ensure that this action has no role or player.
    self = [super initWithRole:nil player:nil playerList:playerList];
    return self;
}


#pragma mark - Overrides


- (NSString *)displayName {
    return NSLocalizedString(@"New Round", nil);
}


- (NSArray *)actors {
    return @[];  // This action has no actors.
}


- (MafiaNumberRange *)numberOfChoices {
    return [MafiaNumberRange numberRangeWithSingleValue:0];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    return NO;
}


@end
