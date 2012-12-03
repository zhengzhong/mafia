//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetup.h"


@implementation MafiaGameSetup


@synthesize playerNames = _playerNames;
@synthesize isTwoHanded = _isTwoHanded;
@synthesize numberOfKillers = _numberOfKillers;
@synthesize numberOfDetectives = _numberOfDetectives;
@synthesize hasAssassin = _hasAssassin;
@synthesize hasGuardian = _hasGuardian;
@synthesize hasDoctor = _hasDoctor;
@synthesize hasTraitor = _hasTraitor;
@synthesize hasUndercover = _hasUndercover;


- (void)dealloc
{
    [_playerNames release];
    [super dealloc];
}


- (id)init
{
    if (self = [super init])
    {
        _playerNames = [[NSMutableArray alloc] initWithCapacity:20];
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


- (void)addPlayerName:(NSString *)playerName
{
    if (![self.playerNames containsObject:playerName])
    {
        [self.playerNames addObject:playerName];
    }
}


- (NSInteger)numberOfPlayersRequired
{
    NSInteger numberOfRoles = self.numberOfKillers + self.numberOfDetectives;
    numberOfRoles += (self.hasAssassin ? 1 : 0);
    numberOfRoles += (self.hasGuardian ? 1 : 0);
    numberOfRoles += (self.hasDoctor ? 1 : 0);
    numberOfRoles += (self.hasTraitor ? 1 : 0);
    numberOfRoles += (self.hasUndercover ? 1 : 0);
    NSInteger numberOfPlayersRequired = ceil(numberOfRoles * (self.isTwoHanded ? 0.7 : 1.4));
    return numberOfPlayersRequired;
}


- (BOOL)isValid
{
    return ([self.playerNames count] >= [self numberOfPlayersRequired]);
}


@end // MafiaGameSetup

