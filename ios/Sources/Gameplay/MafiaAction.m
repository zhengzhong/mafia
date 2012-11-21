#import "MafiaAction.h"
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
    [player selectByRole:[self role]];
    self.isExecuted = YES;
}


- (NSArray *)endAction
{
    return [NSArray arrayWithObjects:nil];
}


@end // MafiaAction



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


@end // MafiaTraitorAction

