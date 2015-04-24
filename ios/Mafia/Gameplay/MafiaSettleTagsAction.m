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


- (NSString *)displayName {
    return NSLocalizedString(@"Settle Tags", nil);
}


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
    // Update previousRoleTags for all players.
    for (MafiaPlayer *player in self.playerList) {
        [player updatePreviousRoleTags];
    }
    // Settle tags in order, and collect information details.
    MafiaInformation *information = [MafiaInformation announcementInformation];
    NSMutableArray *deadPlayerNames = [NSMutableArray arrayWithCapacity:4];
    [information addDetails:[self mafia_settleAssassinTagAndSaveDeadPlayerNamesTo:deadPlayerNames]];
    [information addDetails:[self mafia_settleGuardianTag]];
    [information addDetails:[self mafia_settleKillerTagAndSaveDeadPlayerNamesTo:deadPlayerNames]];
    [information addDetails:[self mafia_settleDoctorTagAndSaveDeadPlayerNamesTo:deadPlayerNames]];
    [information addDetails:[self mafia_settleIntrospectionTags]];
    [information addDetails:[self mafia_settleAssassinToKillerTransition]];
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


- (NSArray *)mafia_settleAssassinTagAndSaveDeadPlayerNamesTo:(NSMutableArray *)deadPlayerNames {
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // If a player is assassined, he's definitely killed.
    BOOL isGuardianKilled = NO;
    NSArray *assassinedPlayers = [self.playerList playersSelectedBy:[MafiaRole assassin] aliveOnly:YES];
    for (MafiaPlayer *assassinedPlayer in assassinedPlayers) {
        [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was assassined", nil), assassinedPlayer]];
        [assassinedPlayer markDead];
        [deadPlayerNames addObject:assassinedPlayer.displayName];
        if ([assassinedPlayer.role isEqualToRole:[MafiaRole guardian]]) {
            isGuardianKilled = YES;
        }
    }
    // If guardian is assassined, the guarded player is also dead.
    // Note: when settling assassin tag, guardian tag has not yet been settled.
    if (isGuardianKilled) {
        NSArray *guardedPlayers = [self.playerList playersSelectedBy:[MafiaRole guardian] aliveOnly:YES];
        for (MafiaPlayer *guardedPlayer in guardedPlayers) {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and was dead with guardian", nil), guardedPlayer]];
            [guardedPlayer markDead];
            [deadPlayerNames addObject:guardedPlayer.displayName];
        }
    }
    return messages;
}


- (NSArray *)mafia_settleGuardianTag {
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // Check the guarded players...
    NSArray *guardedPlayers = [self.playerList playersSelectedBy:[MafiaRole guardian] aliveOnly:YES];
    for (MafiaPlayer *guardedPlayer in guardedPlayers) {
        // If killer is guarded, nobody can be shot except guardian himself.
        if ([guardedPlayer.role isEqualToRole:[MafiaRole killer]]) {
            NSArray *shotPlayers = [self.playerList playersSelectedBy:[MafiaRole killer] aliveOnly:YES];
            for (MafiaPlayer *shotPlayer in shotPlayers) {
                if (![shotPlayer.role isEqualToRole:[MafiaRole guardian]]) {
                    [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and failed to shoot", nil), guardedPlayer]];
                    [shotPlayer clearSelectionTagByRole:[MafiaRole killer]];
                } else {
                    [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%1$@ was guarded and %2$@ was shot", nil), guardedPlayer, shotPlayer]];
                }
            }
        }
        // If doctor is guarded, nobody can be healt.
        if ([guardedPlayer.role isEqualToRole:[MafiaRole doctor]]) {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and failed to heal", nil), guardedPlayer]];
            NSArray *healtPlayers = [self.playerList playersSelectedBy:[MafiaRole doctor] aliveOnly:YES];
            for (MafiaPlayer *healtPlayer in healtPlayers) {
                [healtPlayer clearSelectionTagByRole:[MafiaRole doctor]];
            }
        }
        // If a player is guarded, he cannot be healt.
        if ([guardedPlayer isSelectedByRole:[MafiaRole doctor]]) {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and could not be healt", nil), guardedPlayer]];
            [guardedPlayer clearSelectionTagByRole:[MafiaRole doctor]];
        }
        // If a player is guarded, he cannot be shot, unless he's guardian himself.
        if ([guardedPlayer isSelectedByRole:[MafiaRole killer]]) {
            if (![guardedPlayer.role isEqualToRole:[MafiaRole guardian]]) {
                [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and could not be shot", nil), guardedPlayer]];
                [guardedPlayer clearSelectionTagByRole:[MafiaRole killer]];
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
            [player clearSelectionTagByRole:[MafiaRole guardian]];
        } else {
            player.isJustGuarded = NO;
        }
    }
    // Done.
    return messages;
}


- (NSArray *)mafia_settleKillerTagAndSaveDeadPlayerNamesTo:(NSMutableArray *)deadPlayerNames {
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // If a player is shot, he's killed unless his role is assassin or he's healt.
    BOOL isGuardianKilled = NO;
    NSArray *shotPlayers = [self.playerList playersSelectedBy:[MafiaRole killer] aliveOnly:YES];
    for (MafiaPlayer *shotPlayer in shotPlayers) {
        if ([shotPlayer.role isEqualToRole:[MafiaRole assassin]]) {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ dodged the bullet from killer", nil), shotPlayer]];
            [shotPlayer clearSelectionTagByRole:[MafiaRole killer]];
        } else if ([shotPlayer isSelectedByRole:[MafiaRole doctor]]) {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was shot but healt", nil), shotPlayer]];
            [shotPlayer clearSelectionTagByRole:[MafiaRole killer]];
            [shotPlayer clearSelectionTagByRole:[MafiaRole doctor]];
        } else {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was shot and killed", nil), shotPlayer]];
            [shotPlayer markDead];
            [deadPlayerNames addObject:shotPlayer.displayName];
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
                [deadPlayerNames addObject:player.displayName];
            }
        }
    }
    return messages;
}


- (NSArray *)mafia_settleDoctorTagAndSaveDeadPlayerNamesTo:(NSMutableArray *)deadPlayerNames {
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // If player is misdiagnosed twice, he's killed.
    // Note: killer tag should have already been settled, so no need to check if the healt player
    // is shot by killer. In this stage, all players selected by doctor are misdiagnosed.
    NSArray *healtPlayers = [self.playerList playersSelectedBy:[MafiaRole doctor] aliveOnly:YES];
    for (MafiaPlayer *healtPlayer in healtPlayers) {
        if (healtPlayer.isMisdiagnosed) {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was misdiagnosed twice and killed", nil), healtPlayer]];
            [healtPlayer markDead];
            [deadPlayerNames addObject:healtPlayer.displayName];
        } else {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was misdiagnosed", nil), healtPlayer]];
            healtPlayer.isMisdiagnosed = YES;
            [healtPlayer clearSelectionTagByRole:[MafiaRole doctor]];
        }
    }
    return messages;
}


- (NSArray *)mafia_settleIntrospectionTags {
    for (MafiaPlayer *player in [self.playerList alivePlayers]) {
        [player clearSelectionTagByRole:[MafiaRole detective]];
        [player clearSelectionTagByRole:[MafiaRole traitor]];
        [player clearSelectionTagByRole:[MafiaRole undercover]];
    }
    return @[];
}


- (NSArray *)mafia_settleAssassinToKillerTransition {
    // Assassin becomes killer if he has assassined someone.
    // Note: assassin tags should have been removed from player's currentRoleTags, so we need to
    // check in player's previousRoleTags.
    BOOL needsTransition = NO;
    for (MafiaPlayer *player in self.playerList) {
        if ([player wasSelectedByRole:[MafiaRole assassin]]) {
            needsTransition = YES;
            break;
        }
    }
    if (needsTransition) {
        for (MafiaPlayer *assassin in [self.playerList playersWithRole:[MafiaRole assassin] aliveOnly:YES]) {
            assassin.role = [MafiaRole killer];
        }
    }
    return @[];
}


@end
