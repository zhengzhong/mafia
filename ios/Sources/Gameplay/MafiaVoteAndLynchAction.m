//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaVoteAndLynchAction.h"
#import "MafiaInformation.h"
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


- (MafiaInformation *)endAction
{
    return [self settleVoteAndLynch];
}


- (MafiaInformation *)settleVoteAndLynch
{
    MafiaInformation *information = [MafiaInformation announcementInformation];
    for (MafiaPlayer *player in [self.playerList alivePlayers])
    {
        if (player.isVoted)
        {
            if (player.isJustGuarded)
            {
                information.message = [NSString stringWithFormat:@"%@ was voted but guarded.", player.name];
                player.isVoted = NO;
            }
            else
            {
                information.message = [NSString stringWithFormat:@"%@ was voted and lynched.", player.name];
                [player markDead];
            }
        }
    }
    return information;
}


@end // MafiaVoteAndLynchAction

