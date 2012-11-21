#import "MafiaGame.h"
#import "MafiaAction.h"
#import "MafiaPlayer.h"
#import "MafiaPlayerList.h"
#import "MafiaRole.h"
#import "MafiaSettleTagsAction.h"
#import "MafiaVoteAndLynchAction.h"


@implementation MafiaGame


@synthesize playerList = _playerList;
@synthesize actions = _actions;
@synthesize round = _round;
@synthesize actionIndex = _actionIndex;
@synthesize winner = _winner;


- (void)dealloc
{
    [_playerList release];
    [_actions release];
    [_winner release];
    [super dealloc];
}


- (id)initWithPlayerNames:(NSArray *)playerNames isTwoHanded:(BOOL)isTwoHanded
{
    if (self = [super init])
    {
        _playerList = [[MafiaPlayerList alloc] initWithPlayerNames:playerNames isTwoHanded:isTwoHanded];
        _actions = [[NSArray alloc] initWithObjects:
                    [MafiaGuardianAction actionWithNumberOfActors:1 playerList:_playerList],
                    [MafiaKillerAction actionWithNumberOfActors:2 playerList:_playerList],
                    [MafiaDetectiveAction actionWithNumberOfActors:2 playerList:_playerList],
                    [MafiaDoctorAction actionWithNumberOfActors:1 playerList:_playerList],
                    [MafiaTraitorAction actionWithNumberOfActors:1 playerList:_playerList],
                    [MafiaSettleTagsAction actionWithPlayerList:_playerList],
                    [MafiaVoteAndLynchAction actionWithPlayerList:_playerList],
                    nil];
        _round = 0;
        _actionIndex = 0;
        _winner = nil;
    }
    return self;
}


- (void)reset
{
    [self.playerList reset];
    for (MafiaAction *action in self.actions)
    {
        [action reset];
    }
    self.round = 0;
    self.actionIndex = 0;
    self.winner = nil;
}


- (BOOL)checkGameOver
{
    if (self.round == 0)
    {
        return NO;
    }
    NSArray *killers = [self.playerList alivePlayersWithRole:[MafiaRole killer]];
    if ([killers count] == 0)
    {
        self.winner = @"Civilian Alignment";
        return YES;
    }
    NSArray *detectives = [self.playerList alivePlayersWithRole:[MafiaRole detective]];
    if ([detectives count] == 0)
    {
        self.winner = @"Killer Alignment";
        return YES;
    }
    NSArray *alivePlayers = [self.playerList alivePlayers];
    if ([killers count] * 2 >= [alivePlayers count])
    {
        self.winner = @"Killer Alignment";
        return YES;
    }
    return NO;
}


- (MafiaAction *)currentAction
{
    NSAssert(self.actionIndex >= 0 && self.actionIndex < [self.actions count], @"Invalid action index %d.", self.actionIndex);
    return (self.winner == nil ? [self.actions objectAtIndex:self.actionIndex] : nil);
}


- (MafiaAction *)continueToNextAction
{
    if (![self checkGameOver])
    {
        self.actionIndex = (self.actionIndex + 1) % [self.actions count];
        if (self.actionIndex == 0)
        {
            ++self.round;
        }
    }
    return [self currentAction];
}


@end // MafiaGame

