//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaSettleTagsAction.h"
#import "MafiaInformation.h"
#import "MafiaNumberRange.h"
#import "MafiaPlayer.h"
#import "MafiaPlayerList.h"
#import "MafiaRole.h"


@implementation MafiaSettleTagsAction


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


- (NSArray *)actors {
    return @[];  // This action has no actors.
}


- (MafiaNumberRange *)numberOfChoices {
    return [MafiaNumberRange numberRangeWithSingleValue:0];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    return NO;
}


- (MafiaInformation *)endAction {
    return [self settleTags];
}


#pragma mark - Public


- (MafiaInformation *)settleTags {
    MafiaInformation *information = [MafiaInformation announcementInformation];
    // Settle tags in order, and collect information details.
    NSMutableArray *deadPlayerNames = [NSMutableArray arrayWithCapacity:4];
    [information addDetails:[self _settleAssassinTagAndSaveDeadPlayerNamesTo:deadPlayerNames]];
    [information addDetails:[self _settleGuardianTag]];
    [information addDetails:[self _settleKillerTagAndSaveDeadPlayerNamesTo:deadPlayerNames]];
    [information addDetails:[self _settleDoctorTagAndSaveDeadPlayerNamesTo:deadPlayerNames]];
    [information addDetails:[self _settleIntrospectionTags]];
    // Construct information message as a summary of the settlement result.
    if ([deadPlayerNames count] == 0) {
        information.message = NSLocalizedString(@"Nobody was dead", nil);
    } else if ([deadPlayerNames count] == 1) {
        information.message = [NSString stringWithFormat:NSLocalizedString(@"%@ was dead", nil), deadPlayerNames[0]];
    } else {
        NSString *deadPlayerNamesString = [deadPlayerNames componentsJoinedByString:@", "];
        information.message = [NSString stringWithFormat:NSLocalizedString(@"%@ were dead", nil), deadPlayerNamesString];
    }
    return information;
}


#pragma mark - Private


- (NSArray *)_settleAssassinTagAndSaveDeadPlayerNamesTo:(NSMutableArray *)deadPlayerNames {
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // If a player is assassined, he's definitely killed.
    BOOL isGuardianKilled = NO;
    NSArray *assassinedPlayers = [self.playerList alivePlayersSelectedBy:[MafiaRole assassin]];
    for (MafiaPlayer *assassinedPlayer in assassinedPlayers) {
        [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was assassined", nil), assassinedPlayer]];
        [assassinedPlayer markDead];
        [deadPlayerNames addObject:assassinedPlayer.name];
        if ([assassinedPlayer.role isEqualToRole:[MafiaRole guardian]]) {
            isGuardianKilled = YES;
        }
    }
    // If guardian is assassined, the guarded player is also dead.
    // Note: when settling assassin tag, guardian tag has not yet been settled.
    if (isGuardianKilled) {
        NSArray *guardedPlayers = [self.playerList alivePlayersSelectedBy:[MafiaRole guardian]];
        for (MafiaPlayer *guardedPlayer in guardedPlayers) {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and was dead with guardian", nil), guardedPlayer]];
            [guardedPlayer markDead];
            [deadPlayerNames addObject:guardedPlayer.name];
        }
    }
    return messages;
}


- (NSArray *)_settleGuardianTag {
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // Check the guarded players...
    NSArray *guardedPlayers = [self.playerList alivePlayersSelectedBy:[MafiaRole guardian]];
    for (MafiaPlayer *guardedPlayer in guardedPlayers) {
        // If killer is guarded, nobody can be shot except guardian himself.
        if ([guardedPlayer.role isEqualToRole:[MafiaRole killer]]) {
            NSArray *shotPlayers = [self.playerList alivePlayersSelectedBy:[MafiaRole killer]];
            for (MafiaPlayer *shotPlayer in shotPlayers) {
                if (![shotPlayer.role isEqualToRole:[MafiaRole guardian]]) {
                    [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and failed to shoot", nil), guardedPlayer]];
                    [shotPlayer unselectFromRole:[MafiaRole killer]];
                } else {
                    [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%1$@ was guarded and %2$@ was shot", nil), guardedPlayer, shotPlayer]];
                }
            }
        }
        // If doctor is guarded, nobody can be healt.
        if ([guardedPlayer.role isEqualToRole:[MafiaRole doctor]]) {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and failed to heal", nil), guardedPlayer]];
            NSArray *healtPlayers = [self.playerList alivePlayersSelectedBy:[MafiaRole doctor]];
            for (MafiaPlayer *healtPlayer in healtPlayers) {
                [healtPlayer unselectFromRole:[MafiaRole doctor]];
            }
        }
        // If a player is guarded, he cannot be healt.
        if ([guardedPlayer isSelectedByRole:[MafiaRole doctor]]) {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and could not be healt", nil), guardedPlayer]];
            [guardedPlayer unselectFromRole:[MafiaRole doctor]];
        }
        // If a player is guarded, he cannot be shot, unless he's guardian himself.
        if ([guardedPlayer isSelectedByRole:[MafiaRole killer]]) {
            if (![guardedPlayer.role isEqualToRole:[MafiaRole guardian]]) {
                [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and could not be shot", nil), guardedPlayer]];
                [guardedPlayer unselectFromRole:[MafiaRole killer]];
            }
        }
    }
    // Update isJustGuarded flag for all alive players.
    for (MafiaPlayer *player in [self.playerList alivePlayers]) {
        if ([player isSelectedByRole:[MafiaRole guardian]]) {
            // Make player unguardable if he's guarded twice continuously.
            if (player.isJustGuarded) {
                [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded twice continuously and became unguardable", nil), player]];
                player.isUnguardable = YES;
            }
            player.isJustGuarded = YES;
            [player unselectFromRole:[MafiaRole guardian]];
        } else {
            player.isJustGuarded = NO;
        }
    }
    // Done.
    return messages;
}


- (NSArray *)_settleKillerTagAndSaveDeadPlayerNamesTo:(NSMutableArray *)deadPlayerNames {
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // If a player is shot, he's killed unless his role is assassin or he's healt.
    BOOL isGuardianKilled = NO;
    NSArray *shotPlayers = [self.playerList alivePlayersSelectedBy:[MafiaRole killer]];
    for (MafiaPlayer *shotPlayer in shotPlayers) {
        if ([shotPlayer.role isEqualToRole:[MafiaRole assassin]]) {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ dodged the bullet from killer", nil), shotPlayer]];
            [shotPlayer unselectFromRole:[MafiaRole killer]];
        } else if ([shotPlayer isSelectedByRole:[MafiaRole doctor]]) {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was shot but healt", nil), shotPlayer]];
            [shotPlayer unselectFromRole:[MafiaRole killer]];
            [shotPlayer unselectFromRole:[MafiaRole doctor]];
        } else {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was shot and killed", nil), shotPlayer]];
            [shotPlayer markDead];
            [deadPlayerNames addObject:shotPlayer.name];
            if ([shotPlayer.role isEqualToRole:[MafiaRole guardian]]) {
                isGuardianKilled = YES;
            }
        }
    }
    // If guardian is killed, the guarded player is also dead.
    // Note: guardian tag should have already been settled, so we only check isJustGuarded flag.
    if (isGuardianKilled) {
        for (MafiaPlayer *player in [self.playerList alivePlayers]) {
            if (player.isJustGuarded) {
                [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and was dead with guardian", nil), player]];
                [player markDead];
                [deadPlayerNames addObject:player.name];
            }
        }
    }
    return messages;
}


- (NSArray *)_settleDoctorTagAndSaveDeadPlayerNamesTo:(NSMutableArray *)deadPlayerNames {
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // If player is misdiagnosed twice, he's killed.
    // Note: killer tag should have already been settled, so no need to check if the healt player
    // is shot by killer. In this stage, all players selected by doctor are misdiagnosed.
    NSArray *healtPlayers = [self.playerList alivePlayersSelectedBy:[MafiaRole doctor]];
    for (MafiaPlayer *healtPlayer in healtPlayers) {
        if (healtPlayer.isMisdiagnosed) {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was misdiagnosed twice and killed", nil), healtPlayer]];
            [healtPlayer markDead];
            [deadPlayerNames addObject:healtPlayer.name];
        } else {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was misdiagnosed", nil), healtPlayer]];
            healtPlayer.isMisdiagnosed = YES;
            [healtPlayer unselectFromRole:[MafiaRole doctor]];
        }
    }
    return messages;
}


- (NSArray *)_settleIntrospectionTags {
    for (MafiaPlayer *player in [self.playerList alivePlayers]) {
        [player unselectFromRole:[MafiaRole detective]];
        [player unselectFromRole:[MafiaRole traitor]];
        [player unselectFromRole:[MafiaRole undercover]];
    }
    return [NSArray arrayWithObjects:nil];
}


#pragma mark - NSObject


- (NSString *)description {
    return NSLocalizedString(@"Settle Tags", nil);
}


@end
