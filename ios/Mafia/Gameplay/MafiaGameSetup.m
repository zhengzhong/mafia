//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetup.h"


@implementation MafiaGameSetup


- (id)init {
    if (self = [super init]) {
        _playerNames = [NSMutableArray arrayWithCapacity:20];
        _isTwoHanded = YES;
        _numberOfKillers = 2;
        _numberOfDetectives = 2;
        _hasAssassin = NO;
        _hasGuardian = YES;
        _hasDoctor = YES;
        _hasTraitor = YES;
        _hasUndercover = NO;
    }
    return self;
}


- (void)addPlayerName:(NSString *)playerName {
    if (![self.playerNames containsObject:playerName]) {
        [self.playerNames addObject:playerName];
    }
}


- (NSInteger)numberOfPlayersRequired {
    NSInteger numberOfRoles = self.numberOfKillers + self.numberOfDetectives
        + (self.hasAssassin ? 1 : 0)
        + (self.hasGuardian ? 1 : 0)
        + (self.hasDoctor ? 1 : 0)
        + (self.hasTraitor ? 1 : 0)
        + (self.hasUndercover ? 1 : 0);
    NSInteger numberOfPlayersRequired = ceil(numberOfRoles * (self.isTwoHanded ? 0.7 : 1.4));
    return numberOfPlayersRequired;
}


- (BOOL)isValid {
    return ([self.playerNames count] >= [self numberOfPlayersRequired]);
}


@end  // MafiaGameSetup
