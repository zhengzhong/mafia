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
    return [[self alloc] initWithPlayerList:playerList];
}


- (instancetype)initWithPlayerList:(MafiaPlayerList *)playerList {
    if (self = [super initWithNumberOfActors:0 playerList:playerList]) {
        self.isAssigned = YES;  // This action can never be in a non-assigned status.
    }
    return self;
}


// Override superclass' designated initializer.
- (instancetype)initWithNumberOfActors:(NSInteger)numberOfActors
                            playerList:(MafiaPlayerList *)playerList {
    NSAssert(NO, @"Client should NOT call this initializer.");
    return [self initWithPlayerList:playerList];
}


#pragma mark - Overrides


- (MafiaRole *)role {
    return nil;
}


- (void)reset {
    [super reset];
    self.isAssigned = YES;  // This action can never be in a non-assigned status.
}


- (NSArray *)actors {
    return [self.playerList alivePlayers];
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


#pragma mark - NSObject


- (NSString *)description {
    return NSLocalizedString(@"Vote and Lynch", nil);
}


@end  // MafiaVoteAndLynchAction
