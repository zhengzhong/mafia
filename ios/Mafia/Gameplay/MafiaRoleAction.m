//
//  Created by ZHENG Zhong on 2015-04-10.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaRoleAction.h"
#import "MafiaInformation.h"
#import "MafiaNumberRange.h"
#import "MafiaPlayer.h"
#import "MafiaPlayerList.h"
#import "MafiaRole.h"


// ------------------------------------------------------------------------------------------------
// MafiaRoleAction subclasses
// ------------------------------------------------------------------------------------------------


@interface MafiaCivilianAction : MafiaRoleAction

@end


@interface MafiaAssassinAction : MafiaRoleAction

@property (assign, nonatomic) BOOL isChanceUsed;

@end


@interface MafiaGuardianAction : MafiaRoleAction

@end


@interface MafiaKillerAction : MafiaRoleAction

@end


@interface MafiaDetectiveAction : MafiaRoleAction

@end


@interface MafiaDoctorAction : MafiaRoleAction

@end


@interface MafiaTraitorAction : MafiaRoleAction

@end


@interface MafiaUndercoverAction : MafiaRoleAction

@end


// ------------------------------------------------------------------------------------------------
// MafiaRoleAction
// ------------------------------------------------------------------------------------------------


@implementation MafiaRoleAction


+ (MafiaRole *)roleOfAction {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


+ (instancetype)actionWithRole:(MafiaRole *)role
                        player:(MafiaPlayer *)player
                    playerList:(MafiaPlayerList *)playerList {
    static NSDictionary *actionClassMappings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actionClassMappings = @{
            [MafiaCivilianAction roleOfAction]: [MafiaCivilianAction class],
            [MafiaAssassinAction roleOfAction]: [MafiaAssassinAction class],
            [MafiaGuardianAction roleOfAction]: [MafiaGuardianAction class],
            [MafiaKillerAction roleOfAction]: [MafiaKillerAction class],
            [MafiaDetectiveAction roleOfAction]: [MafiaDetectiveAction class],
            [MafiaDoctorAction roleOfAction]: [MafiaDoctorAction class],
            [MafiaTraitorAction roleOfAction]: [MafiaTraitorAction class],
            [MafiaUndercoverAction roleOfAction]: [MafiaUndercoverAction class],
        };
    });
    Class actionClass = actionClassMappings[role];
    if (actionClass == nil) {
        @throw [NSException exceptionWithName:MafiaInvalidActionRoleException
                                       reason:[NSString stringWithFormat:@"Cannot find action class for role %@.", role]
                                     userInfo:nil];
    }
    return [[actionClass alloc] initWithRole:role player:player playerList:playerList];
}


- (instancetype)initWithRole:(MafiaRole *)role
                      player:(MafiaPlayer *)player
                  playerList:(MafiaPlayerList *)playerList {
    MafiaRole *roleOfAction = [[self class] roleOfAction];
    NSAssert(role == roleOfAction || [role isEqualToRole:roleOfAction], @"Role does not match action.");
    self = [super initWithRole:role player:player playerList:playerList];
    return self;
}


- (void)executeOnPlayer:(MafiaPlayer *)player {
    [super executeOnPlayer:player];
    [player selectByRole:self.role];
}


@end


// ------------------------------------------------------------------------------------------------
// MafiaCivilianAction
// ------------------------------------------------------------------------------------------------


@implementation MafiaCivilianAction


+ (MafiaRole *)roleOfAction {
    return [MafiaRole civilian];
}


- (MafiaNumberRange *)numberOfChoices {
    return [MafiaNumberRange numberRangeWithSingleValue:0];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    return NO;
}


@end


// ------------------------------------------------------------------------------------------------
// MafiaAssassinAction
// ------------------------------------------------------------------------------------------------


@implementation MafiaAssassinAction


+ (MafiaRole *)roleOfAction {
    return [MafiaRole assassin];
}


- (MafiaNumberRange *)numberOfChoices {
    return [MafiaNumberRange numberRangeWithMinValue:0 maxValue:1];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    return !player.isDead;
}


- (void)executeOnPlayer:(MafiaPlayer *)player {
    NSAssert(!self.isChanceUsed, @"Assassin has already used his chance and cannot execute again.");
    [super executeOnPlayer:player];
    self.isChanceUsed = YES;
}


- (MafiaInformation *)endAction {
    MafiaInformation *information = nil;
    if (self.isChanceUsed) {
        // Assassin becomes a killer after using his chance to shoot.
        for (MafiaPlayer *assassin in [self actors]) {
            assassin.role = [MafiaRole killer];
        }
        information = [MafiaInformation announcementInformation];
        information.message = NSLocalizedString(@"Assassin used his chance to shoot and became killer.", nil);
    }
    return information;
}


@end


// ------------------------------------------------------------------------------------------------
// MafiaGuardianAction
// ------------------------------------------------------------------------------------------------


@implementation MafiaGuardianAction


+ (MafiaRole *)roleOfAction {
    return [MafiaRole guardian];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    return (!player.isDead && !player.isUnguardable);
}


@end


// ------------------------------------------------------------------------------------------------
// MafiaKillerAction
// ------------------------------------------------------------------------------------------------


@implementation MafiaKillerAction


+ (MafiaRole *)roleOfAction {
    return [MafiaRole killer];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    // In autonomic mode, if one killer has already selected a player in the current round,
    // only that same player is selectable by any other killers.
    if (self.player != nil) {
        NSArray *selectedPlayers = [self.playerList playersSelectedBy:self.role aliveOnly:YES];
        if ([selectedPlayers count] > 0) {
            return [selectedPlayers containsObject:player];
        }
    }
    // Otherwise, alive players are all selectable.
    return !player.isDead;
}


@end


// ------------------------------------------------------------------------------------------------
// MafiaDetectiveAction
// ------------------------------------------------------------------------------------------------


@implementation MafiaDetectiveAction


+ (MafiaRole *)roleOfAction {
    return [MafiaRole detective];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    // In autonomic mode, if one detective has already selected a player in the current round,
    // only that same player is selectable by any other detectives.
    if (self.player != nil) {
        NSArray *selectedPlayers = [self.playerList playersSelectedBy:self.role aliveOnly:NO];
        if ([selectedPlayers count] > 0) {
            return [selectedPlayers containsObject:player];
        }
    }
    // Otherwise: Detective can check any non-detective player, even if he's dead.
    return (![player.role isEqualToRole:self.role]);
}


- (MafiaInformation *)endAction {
    NSArray *selectedPlayers = [self.playerList playersSelectedBy:self.role aliveOnly:NO];
    BOOL isPositive = NO;
    for (MafiaPlayer *player in selectedPlayers) {
        if ([player.role isEqualToRole:[MafiaRole killer]]) {
            isPositive = YES;
        }
    }
    return [MafiaInformation informationWithAnswer:isPositive];
}


@end


// ------------------------------------------------------------------------------------------------
// MafiaDoctorAction
// ------------------------------------------------------------------------------------------------


@implementation MafiaDoctorAction


+ (MafiaRole *)roleOfAction {
    return [MafiaRole doctor];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    return !player.isDead;
}


@end


// ------------------------------------------------------------------------------------------------
// MafiaTraitorAction
// ------------------------------------------------------------------------------------------------


@implementation MafiaTraitorAction


+ (MafiaRole *)roleOfAction {
    return [MafiaRole traitor];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    // Traitor can check any non-traitor player, even if he's dead.
    return (![player.role isEqualToRole:self.role]);
}


- (MafiaInformation *)endAction {
    NSArray *selectedPlayers = [self.playerList playersSelectedBy:self.role aliveOnly:NO];
    BOOL isPositive = NO;
    for (MafiaPlayer *player in selectedPlayers) {
        if ([player.role isEqualToRole:[MafiaRole killer]] || [player.role isEqualToRole:[MafiaRole assassin]]) {
            isPositive = YES;
        }
    }
    return [MafiaInformation informationWithAnswer:isPositive];
}


@end


// ------------------------------------------------------------------------------------------------
// MafiaUndercoverAction
// ------------------------------------------------------------------------------------------------


@implementation MafiaUndercoverAction


+ (MafiaRole *)roleOfAction {
    return [MafiaRole undercover];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    // Undercover can check any non-undercover player, even if he's dead.
    return (![player.role isEqualToRole:self.role]);
}


- (MafiaInformation *)endAction {
    NSArray *selectedPlayers = [self.playerList playersSelectedBy:self.role aliveOnly:NO];
    BOOL isPositive = NO;
    for (MafiaPlayer *player in selectedPlayers) {
        if ([player.role isEqualToRole:[MafiaRole killer]] || [player.role isEqualToRole:[MafiaRole assassin]]) {
            isPositive = YES;
        }
    }
    return [MafiaInformation informationWithAnswer:isPositive];
}


@end
