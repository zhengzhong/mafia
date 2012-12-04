//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAction.h"
#import "MafiaInformation.h"
#import "MafiaPlayer.h"
#import "MafiaPlayerList.h"
#import "MafiaRole.h"


@implementation MafiaAction


@synthesize numberOfActors = _numberOfActors;
@synthesize playerList = _playerList;
@synthesize isAssigned = _isAssigned;
@synthesize isExecuted = _isExecuted;


- (void)dealloc
{
    [_playerList release];
    [super dealloc];
}


- (id)initWithNumberOfActors:(NSInteger)numberOfActors playerList:(MafiaPlayerList *)playerList
{
    if (self = [super init])
    {
        _numberOfActors = numberOfActors;
        _playerList = [playerList retain];
        _isAssigned = NO;
        _isExecuted = NO;
    }
    return self;
}


+ (id)actionWithNumberOfActors:(NSInteger)numberOfActors playerList:(MafiaPlayerList *)playerList
{
    return [[[self alloc] initWithNumberOfActors:numberOfActors playerList:playerList] autorelease];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ Action", [self role]];
}


- (MafiaRole *)role
{
    return nil;
}


- (void)reset
{
    self.isAssigned = NO;
    self.isExecuted = NO;
}


- (void)assignRoleToPlayers:(NSArray *)players
{
    if (self.isAssigned || [self role] == nil)
    {
        return;
    }
    NSAssert([players count] == self.numberOfActors, @"Invalid number of actors: expected %d.", self.numberOfActors);
    for (MafiaPlayer *player in players)
    {
        NSAssert([player isUnrevealed], @"Player %@ was already assigned as %@.", player, player.role);
        player.role = [self role];
    }
    self.isAssigned = YES;
}


- (NSArray *)actors
{
    return [self.playerList alivePlayersWithRole:[self role]];
}


- (BOOL)isExecutable
{
    return ([[self actors] count] > 0);
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player
{
    return !player.isDead;
}


- (void)beginAction
{
    self.isExecuted = NO;
}


- (void)executeOnPlayer:(MafiaPlayer *)player
{
    NSAssert(!self.isExecuted, @"%@ is already executed.", self);
    NSAssert([self isPlayerSelectable:player], @"%@ cannot select %@.", [self role], player);
    [player selectByRole:[self role]];
    self.isExecuted = YES;
}


- (MafiaInformation *)endAction
{
    return nil;
}


@end // MafiaAction


@implementation MafiaAssassinAction : MafiaAction


@synthesize isChanceUsed = _isChanceUsed;


- (id)initWithNumberOfActors:(NSInteger)numberOfActors playerList:(MafiaPlayerList *)playerList
{
    if (self = [super initWithNumberOfActors:numberOfActors playerList:playerList])
    {
        _isChanceUsed = NO;
    }
    return self;
}


- (MafiaRole *)role
{
    return [MafiaRole assassin];
}


- (void)executeOnPlayer:(MafiaPlayer *)player
{
    NSAssert(!self.isChanceUsed, @"Assassin has already used his chance and cannot execute again.");
    [super executeOnPlayer:player];
    self.isChanceUsed = YES;
}


- (MafiaInformation *)endAction
{
    // Assassin becomes a killer after using his chance to shoot.
    if (self.isChanceUsed)
    {
        for (MafiaPlayer *assassin in [self actors])
        {
            assassin.role = [MafiaRole killer];
        }
    }
    return nil;
}


@end // MafiaAssassinAction


@implementation MafiaGuardianAction


- (MafiaRole *)role
{
    return [MafiaRole guardian];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player
{
    return (!player.isDead && !player.isUnguardable);
}


@end // MafiaGuardianAction


@implementation MafiaKillerAction


- (MafiaRole *)role
{
    return [MafiaRole killer];
}


@end // MafiaKillerAction


@implementation MafiaDetectiveAction


- (MafiaRole *)role
{
    return [MafiaRole detective];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player
{
    return (player.role != [self role]);
}


- (MafiaInformation *)endAction
{
    NSArray *introspectedPlayers = [self.playerList alivePlayersSelectedBy:[self role]];
    BOOL isPositive = NO;
    for (MafiaPlayer *player in introspectedPlayers)
    {
        if (player.role == [MafiaRole killer])
        {
            isPositive = YES;
        }
    }
    return [MafiaInformation thumbInformationWithIndicator:isPositive];
}


@end // MafiaDetectiveAction


@implementation MafiaDoctorAction


- (MafiaRole *)role
{
    return [MafiaRole doctor];
}


@end // MafiaDoctorAction


@implementation MafiaTraitorAction


- (MafiaRole *)role
{
    return [MafiaRole traitor];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player
{
    return (player.role != [self role]);
}


- (MafiaInformation *)endAction
{
    NSArray *introspectedPlayers = [self.playerList alivePlayersSelectedBy:[self role]];
    BOOL isPositive = NO;
    for (MafiaPlayer *player in introspectedPlayers)
    {
        if (player.role == [MafiaRole killer] || player.role == [MafiaRole assassin])
        {
            isPositive = YES;
        }
    }
    return [MafiaInformation thumbInformationWithIndicator:isPositive];
}


@end // MafiaTraitorAction


@implementation MafiaUndercoverAction : MafiaAction


- (MafiaRole *)role
{
    return [MafiaRole undercover];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player
{
    return (player.role != [self role]);
}


- (MafiaInformation *)endAction
{
    NSArray *introspectedPlayers = [self.playerList alivePlayersSelectedBy:[self role]];
    BOOL isPositive = NO;
    for (MafiaPlayer *player in introspectedPlayers)
    {
        if (player.role == [MafiaRole killer] || player.role == [MafiaRole assassin])
        {
            isPositive = YES;
        }
    }
    return [MafiaInformation thumbInformationWithIndicator:isPositive];
}


@end // MafiaUndercoverAction

