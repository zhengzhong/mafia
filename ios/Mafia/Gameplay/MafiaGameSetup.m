//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetup.h"
#import "MafiaRole.h"


@implementation MafiaGameSetup


- (id)init {
    if (self = [super init]) {
        _playerNames = [NSMutableArray arrayWithCapacity:20];
        _isTwoHanded = YES;
        _roleSettings = [@{
            [MafiaRole killer]: @2,
            [MafiaRole detective]: @2,
            [MafiaRole assassin]: @0,
            [MafiaRole guardian]: @1,
            [MafiaRole doctor]: @1,
            [MafiaRole traitor]: @1,
            [MafiaRole undercover]: @0,
        } mutableCopy];
    }
    return self;
}


- (void)addPlayerName:(NSString *)playerName {
    if (![self.playerNames containsObject:playerName]) {
        [self.playerNames addObject:playerName];
    }
}


- (NSInteger)numberOfActorsForRole:(MafiaRole *)role {
    return [self.roleSettings[role] intValue];
}


- (void)setNumberOfActors:(NSInteger)numberOfActors forRole:(MafiaRole *)role {
    self.roleSettings[role] = @(numberOfActors);
}


- (NSInteger)numberOfPlayersRequired {
    NSInteger numberOfRoles = 0;
    for (MafiaRole *role in self.roleSettings) {
        numberOfRoles += [self.roleSettings[role] intValue];
    }
    return (NSInteger)ceil(numberOfRoles * (self.isTwoHanded ? 0.7 : 1.4));
}


- (BOOL)isValid {
    return ([self.playerNames count] >= [self numberOfPlayersRequired]);
}


@end
