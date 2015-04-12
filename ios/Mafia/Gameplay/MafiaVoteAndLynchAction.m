//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaVoteAndLynchAction.h"
#import "MafiaInformation.h"
#import "MafiaPlayer.h"
#import "MafiaPlayerList.h"


@implementation MafiaVoteAndLynchAction


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
    return NSLocalizedString(@"Vote and Lynch", nil);
}


- (NSArray *)actors {
    return [self.playerList alivePlayers];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    return !player.isDead;
}


- (void)executeOnPlayer:(MafiaPlayer *)player {
    NSAssert(!self.isExecuted, @"%@ is already executed.", self);
    player.isVoted = YES;
    self.isExecuted = YES;
}


- (MafiaInformation *)endAction {
    return [self settleVoteAndLynch];
}


#pragma mark - Public


- (MafiaInformation *)settleVoteAndLynch {
    MafiaInformation *information = [MafiaInformation announcementInformation];
    for (MafiaPlayer *player in [self.playerList alivePlayers]) {
        if (player.isVoted) {
            if (player.isJustGuarded) {
                information.message = [NSString stringWithFormat:NSLocalizedString(@"%@ was voted but guarded", nil), player.name];
                player.isVoted = NO;
            } else {
                information.message = [NSString stringWithFormat:NSLocalizedString(@"%@ was voted and lynched", nil), player.name];
                [player markDead];
            }
        }
    }
    return information;
}


@end
