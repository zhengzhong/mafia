//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGame.h"
#import "MafiaAction.h"
#import "MafiaGameSetup.h"
#import "MafiaPerson.h"
#import "MafiaPlayer.h"
#import "MafiaPlayerList.h"
#import "MafiaRole.h"
#import "MafiaRoleAction.h"
#import "MafiaSettleTagsAction.h"
#import "MafiaVoteAndLynchAction.h"


@interface MafiaGame ()

@property (assign, nonatomic) NSInteger round;
@property (assign, nonatomic) NSInteger actionIndex;
@property (assign, nonatomic) MafiaWinner winner;

@end


@implementation MafiaGame


- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Unavailable"
                                 userInfo:nil];
}


- (instancetype)initWithPersons:(NSArray *)persons isTwoHanded:(BOOL)isTwoHanded {
    MafiaGameSetup *gameSetup = [[MafiaGameSetup alloc] init];
    for (MafiaPerson *person in persons) {
        [gameSetup addPerson:person];
    }
    gameSetup.isTwoHanded = isTwoHanded;
    return [self initWithGameSetup:gameSetup];
}


- (instancetype)initWithGameSetup:(MafiaGameSetup *)gameSetup {
    NSAssert([gameSetup isValid], @"Game setup is invalid.");
    if (self = [super init]) {
        _gameSetup = gameSetup;
        _playerList = [[MafiaPlayerList alloc] initWithPersons:gameSetup.persons
                                                   isTwoHanded:gameSetup.isTwoHanded];
        _actions = [[NSMutableArray alloc] initWithCapacity:20];
        _winner = MafiaWinnerUnknown;
    }
    return self;
}


- (void)reset {
    [self.playerList reset];
    [self.actions removeAllObjects];
    self.round = 0;
    self.actionIndex = 0;
    self.winner = MafiaWinnerUnknown;
}


- (BOOL)checkGameOver {
    NSArray *aliveKillers = [self.playerList playersWithRole:[MafiaRole killer] aliveOnly:YES];
    NSArray *aliveAssassins = [self.playerList playersWithRole:[MafiaRole assassin] aliveOnly:YES];
    if ([aliveKillers count] == 0 && [aliveAssassins count] == 0) {
        self.winner = MafiaWinnerCivilians;
        return YES;
    }

    NSArray *aliveDetectives = [self.playerList playersWithRole:[MafiaRole detective] aliveOnly:YES];
    NSArray *aliveUndercovers = [self.playerList playersWithRole:[MafiaRole undercover] aliveOnly:YES];
    if ([aliveDetectives count] == 0 && [aliveUndercovers count] == 0) {
        self.winner = MafiaWinnerKillers;
        return YES;
    }

    NSArray *alivePlayers = [self.playerList alivePlayers];
    if ([aliveKillers count] * 2 >= [alivePlayers count]) {
        self.winner = MafiaWinnerKillers;
        return YES;
    }

    return NO;
}


- (void)assignRole:(MafiaRole *)role toPlayers:(NSArray *)players {
    NSInteger numberOfActors = [self.gameSetup numberOfActorsForRole:role];
    NSAssert([players count] == numberOfActors, @"Invalid number of actors: expected %@.", @(numberOfActors));
    for (MafiaPlayer *player in self.playerList) {
        if ([player.role isEqualToRole:role]) {
            player.role = nil;
        }
    }
    for (MafiaPlayer *player in players) {
        NSAssert(player.role == nil, @"Player %@ was already assigned as %@.", player, player.role);
        player.role = role;
    }
}


- (void)assignCivilianRoleToUnassignedPlayers {
    for (MafiaPlayer *player in self.playerList) {
        if (player.role == nil) {
            player.role = [MafiaRole civilian];
        }
    }
}


- (void)assignRolesRandomly {
    // Reset all players to unrevealed.
    for (MafiaPlayer *player in self.playerList) {
        player.role = nil;
    }
    // Shuffle the players <http://stackoverflow.com/questions/56648/>.
    NSMutableArray *shuffledPlayers = [self.playerList.players mutableCopy];
    NSUInteger numberOfPlayers = [shuffledPlayers count];
    for (NSUInteger i = 0; i < numberOfPlayers; ++i) {
        NSInteger remainingCount = numberOfPlayers - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
        [shuffledPlayers exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    // Create an array of roles to assign: the number of roles should match the number of players.
    // Note: roles with highest absolute value of alignment should be assigned first, to avoid potential conflicts.
    NSMutableArray *rolesToAssign = [[NSMutableArray alloc] initWithCapacity:numberOfPlayers];
    NSArray *specialRoles = @[
        [MafiaRole killer],
        [MafiaRole detective],
        [MafiaRole assassin],
        [MafiaRole undercover],
        [MafiaRole traitor],
        [MafiaRole guardian],
        [MafiaRole doctor],
    ];
    for (MafiaRole *role in specialRoles) {
        NSInteger numberOfActors = [self.gameSetup numberOfActorsForRole:role];
        for (NSInteger i = 0; i < numberOfActors; ++i) {
            [rolesToAssign addObject:role];
        }
    }
    for (NSUInteger i = [rolesToAssign count]; i < numberOfPlayers; ++i) {
        [rolesToAssign addObject:[MafiaRole civilian]];
    }
    NSAssert([rolesToAssign count] == numberOfPlayers, @"Number of roles does not match number of players.");
    // Assign roles to players, avoiding any possible conflicts.
    for (MafiaRole *role in rolesToAssign) {
        MafiaPlayer *assignedPlayer = nil;
        for (MafiaPlayer *player in shuffledPlayers) {
            MafiaPlayer *twinPlayer = [self.playerList twinOfPlayer:player];
            if (twinPlayer == nil || twinPlayer.role.alignment + role.alignment != 0) {
                player.role = role;
                assignedPlayer = player;
                break;
            }
        }
        NSAssert(assignedPlayer != nil, @"Role should have been assigned to one player.");
        [shuffledPlayers removeObject:assignedPlayer];
    }
    NSAssert([shuffledPlayers count] == 0, @"All players should have been assigned.");
}


- (BOOL)isReadyToStart {
    for (MafiaPlayer *player in self.playerList) {
        if (player.role == nil) {
            return NO;
        }
    }
    return YES;
}


- (void)startGame {
    NSAssert([self isReadyToStart], @"Game is not ready to start.");
    [self.playerList prepareToStart];
    [self.actions removeAllObjects];
    if (!self.gameSetup.isAutonomic) {
        // Non-autonomic mode: a judge is required.
        NSArray *specialRolesByActingOrder = @[
            [MafiaRole assassin],
            [MafiaRole guardian],
            [MafiaRole killer],
            [MafiaRole detective],
            [MafiaRole doctor],
            [MafiaRole traitor],
            [MafiaRole undercover],
        ];
        for (MafiaRole *role in specialRolesByActingOrder) {
            if ([self.gameSetup numberOfActorsForRole:role] > 0) {
                MafiaAction *action = [MafiaRoleAction actionWithRole:role
                                                               player:nil
                                                           playerList:self.playerList];
                [self.actions addObject:action];
            }
        }
    } else {
        // Autonomic mode: there is no judge, players act one-by-one.
        for (MafiaPlayer *player in self.playerList) {
            MafiaAction *action = [MafiaRoleAction actionWithRole:player.role
                                                           player:player
                                                       playerList:self.playerList];
            [self.actions addObject:action];
        }
    }
    [self.actions addObject:[MafiaSettleTagsAction actionWithPlayerList:self.playerList]];
    [self.actions addObject:[MafiaVoteAndLynchAction actionWithPlayerList:self.playerList]];
    self.round = 0;
    self.actionIndex = 0;
    self.winner = MafiaWinnerUnknown;
}


- (MafiaAction *)currentAction {
    NSAssert(self.actionIndex >= 0 && self.actionIndex < [self.actions count],
             @"Invalid action index %@.", @(self.actionIndex));
    return (self.winner == MafiaWinnerUnknown ? self.actions[self.actionIndex] : nil);
}


- (MafiaAction *)continueToNextAction {
    if (![self checkGameOver]) {
        // Find the index of the next available action. In autonomic mode, if an action's player is
        // dead, the action is skipped.
        NSInteger nextActionIndex = 0;
        for (NSInteger i = 1; i <= [self.actions count]; ++i) {
            nextActionIndex = (self.actionIndex + i) % [self.actions count];
            MafiaAction *action = self.actions[nextActionIndex];
            if (action.player == nil || !action.player.isDead) {
                break;
            }
        }
        NSAssert(nextActionIndex != self.actionIndex, @"Cannot find next available action.");
        if (nextActionIndex < self.actionIndex) {
            // We rewind back to a preceding action, so a new round begins.
            ++self.round;
            // In autonomic mode, assassin action might be transformed to killer action if assassin
            // has used his chance. So we check if action's role still matches its player's role.
            for (NSUInteger i = 0; i < [self.actions count]; ++i) {
                MafiaAction *action = self.actions[i];
                if (action.player != nil && ![action.player.role isEqualToRole:action.role]) {
                    MafiaAction *newAction = [MafiaRoleAction actionWithRole:action.player.role
                                                                      player:action.player
                                                                  playerList:self.playerList];
                    [self.actions replaceObjectAtIndex:i withObject:newAction];
                }
            }
        }
        // Update action index.
        self.actionIndex = nextActionIndex;
    }
    return [self currentAction];
}


@end
