#import "MafiaVoteAndLynchAction.h"
#import "MafiaPlayer.h"
#import "MafiaPlayerList.h"


@implementation MafiaVoteAndLynchAction


- (id)initWithPlayerList:(MafiaPlayerList *)playerList
{
    if (self = [super initWithNumberOfActors:0 playerList:playerList])
    {
        self.isAssigned = YES; // TODO:
    }
    return self;
}


+ (id)actionWithPlayerList:(MafiaPlayerList *)playerList
{
    return [[[self alloc] initWithPlayerList:playerList] autorelease];
}


- (NSString *)description
{
    return @"Vote and Lynch";
}


- (MafiaRole *)role
{
    return nil;
}


- (void)reset
{
    [super reset];
    self.isAssigned = YES;
}


- (NSArray *)actors
{
    return [self.playerList alivePlayers];
}


- (void)executeOnPlayer:(MafiaPlayer *)player
{
    NSAssert(!self.isExecuted, @"%@ is already executed.", self);
    player.isVoted = YES;
    self.isExecuted = YES;
}


- (NSArray *)endAction
{
    return [self settleVoteAndLynch];
}


- (NSArray *)settleVoteAndLynch
{
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    for (MafiaPlayer *player in [self.playerList alivePlayers])
    {
        if (player.isVoted)
        {
            if (player.isJustGuarded)
            {
                [messages addObject:[NSString stringWithFormat:@"%@ was voted but guarded.", player]];
                player.isVoted = NO;
            }
            else
            {
                [messages addObject:[NSString stringWithFormat:@"%@ was voted and lynched.", player]];
                [player markDead];
            }
        }
    }
    return messages;
}


@end // MafiaVoteAndLynchAction

