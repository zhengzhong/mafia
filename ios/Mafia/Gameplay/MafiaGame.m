//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGame.h"
#import "MafiaAction.h"
#import "MafiaGameSetup.h"
#import "MafiaPlayer.h"
#import "MafiaPlayerList.h"
#import "MafiaRole.h"
#import "MafiaSettleTagsAction.h"
#import "MafiaVoteAndLynchAction.h"


@implementation MafiaGame


- (instancetype)initWithPlayerNames:(NSArray *)playerNames isTwoHanded:(BOOL)isTwoHanded {
    MafiaGameSetup *gameSetup = [[MafiaGameSetup alloc] init];
    for (NSString *playerName in playerNames) {
        [gameSetup addPlayerName:playerName];
    }
    gameSetup.isTwoHanded = isTwoHanded;
    return [self initWithGameSetup:gameSetup];
}


- (instancetype)initWithGameSetup:(MafiaGameSetup *)gameSetup {
    NSAssert([gameSetup isValid], @"Game setup is invalid.");
    if (self = [super init]) {
        _gameSetup = gameSetup;
        _playerList = [[MafiaPlayerList alloc] initWithPlayerNames:gameSetup.playerNames
                                                       isTwoHanded:gameSetup.isTwoHanded];
    }
    return self;
}


- (void)reset {
    [self.playerList reset];
    self.actions = nil;
    self.round = 0;
    self.actionIndex = 0;
    self.winner = nil;
}


- (BOOL)checkGameOver {
    NSArray *unrevealedPlayers = [self.playerList alivePlayersWithRole:[MafiaRole unrevealed]];
    if ([unrevealedPlayers count] > 0) {
        return NO;
    }
    NSArray *aliveKillers = [self.playerList alivePlayersWithRole:[MafiaRole killer]];
    if ([aliveKillers count] == 0) {
        self.winner = NSLocalizedString(@"Civilian Alignment", nil);
        return YES;
    }
    NSArray *aliveDetectives = [self.playerList alivePlayersWithRole:[MafiaRole detective]];
    if ([aliveDetectives count] == 0) {
        self.winner = NSLocalizedString(@"Killer Alignment", nil);
        return YES;
    }
    NSArray *alivePlayers = [self.playerList alivePlayers];
    if ([aliveKillers count] * 2 >= [alivePlayers count]) {
        self.winner = NSLocalizedString(@"Killer Alignment", nil);
        return YES;
    }
    return NO;
}


- (void)assignRole:(MafiaRole *)role toPlayers:(NSArray *)players {
    NSInteger numberOfActors = [self.gameSetup numberOfActorsForRole:role];
    NSAssert([players count] == numberOfActors, @"Invalid number of actors: expected %@.", @(numberOfActors));
    for (MafiaPlayer *player in self.playerList) {
        if ([player.role isEqualToRole:role]) {
            player.role = [MafiaRole unrevealed];
        }
    }
    for (MafiaPlayer *player in players) {
        NSAssert(player.isUnrevealed, @"Player %@ was already assigned as %@.", player, player.role);
        player.role = role;
    }
}


- (void)assignCivilianRoleToUnrevealedPlayers {
    for (MafiaPlayer *player in self.playerList) {
        if (player.isUnrevealed) {
            player.role = [MafiaRole civilian];
        }
    }
}


- (BOOL)isReadyToStart {
    for (MafiaPlayer *player in self.playerList) {
        if (player.isUnrevealed) {
            return NO;
        }
    }
    return YES;
}


- (void)startGame {
    NSAssert([self isReadyToStart], @"Game is not ready to start.");
    [self.playerList prepareToStart];
    NSMutableArray *actions = [[NSMutableArray alloc] initWithCapacity:10];
    if ([self.gameSetup numberOfActorsForRole:[MafiaRole assassin]] > 0) {
        [actions addObject:[MafiaAssassinAction actionWithPlayerList:self.playerList]];
    }
    if ([self.gameSetup numberOfActorsForRole:[MafiaRole guardian]] > 0) {
        [actions addObject:[MafiaGuardianAction actionWithPlayerList:self.playerList]];
    }
    if ([self.gameSetup numberOfActorsForRole:[MafiaRole killer]] > 0) {
        [actions addObject:[MafiaKillerAction actionWithPlayerList:self.playerList]];
    }
    if ([self.gameSetup numberOfActorsForRole:[MafiaRole detective]] > 0) {
        [actions addObject:[MafiaDetectiveAction actionWithPlayerList:self.playerList]];
    }
    if ([self.gameSetup numberOfActorsForRole:[MafiaRole doctor]] > 0) {
        [actions addObject:[MafiaDoctorAction actionWithPlayerList:self.playerList]];
    }
    if ([self.gameSetup numberOfActorsForRole:[MafiaRole traitor]] > 0) {
        [actions addObject:[MafiaTraitorAction actionWithPlayerList:self.playerList]];
    }
    if ([self.gameSetup numberOfActorsForRole:[MafiaRole undercover]] > 0) {
        [actions addObject:[MafiaUndercoverAction actionWithPlayerList:self.playerList]];
    }
    [actions addObject:[MafiaSettleTagsAction actionWithPlayerList:self.playerList]];
    [actions addObject:[MafiaVoteAndLynchAction actionWithPlayerList:self.playerList]];
    self.actions = [actions copy];
    self.round = 0;
    self.actionIndex = 0;
    self.winner = nil;
}


- (MafiaAction *)currentAction {
    NSAssert(self.actionIndex >= 0 && self.actionIndex < [self.actions count],
             @"Invalid action index %@.", @(self.actionIndex));
    return (self.winner == nil ? self.actions[self.actionIndex] : nil);
}


- (MafiaAction *)continueToNextAction {
    if (![self checkGameOver]) {
        self.actionIndex = (self.actionIndex + 1) % [self.actions count];
        if (self.actionIndex == 0) {
            ++self.round;
        }
    }
    return [self currentAction];
}


@end
