//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAction.h"
#import "MafiaInformation.h"
#import "MafiaNumberRange.h"
#import "MafiaPlayer.h"
#import "MafiaPlayerList.h"
#import "MafiaRole.h"


@implementation MafiaAction


#pragma mark - Properties


@dynamic role;

- (MafiaRole *)role {
    return nil;
}


#pragma mark - Factory Method and Initializer


+ (instancetype)actionWithPlayerList:(MafiaPlayerList *)playerList {
    return [[self alloc] initWithPlayerList:playerList];
}


- (instancetype)initWithPlayerList:(MafiaPlayerList *)playerList {
    if (self = [super init]) {
        _playerList = playerList;
        _isExecuted = NO;
    }
    return self;
}


#pragma mark - NSObject


- (NSString *)description {
    return [NSString stringWithFormat:NSLocalizedString(@"%@ Action", nil), self.role];
}


#pragma mark - Public Methods


- (NSArray *)actors {
    return [self.playerList alivePlayersWithRole:self.role];
}


- (BOOL)isExecutable {
    return ([[self actors] count] > 0);
}


- (MafiaNumberRange *)numberOfChoices {
    // By default, in each action, 1 player can be selected.
    return [MafiaNumberRange numberRangeWithSingleValue:1];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    return !player.isDead;
}


- (void)beginAction {
    self.isExecuted = NO;
}


- (void)executeOnPlayer:(MafiaPlayer *)player {
    NSAssert(!self.isExecuted, @"%@ is already executed.", self);
    NSAssert([self isPlayerSelectable:player], @"%@ cannot select %@.", self.role, player);
    [player selectByRole:self.role];
    self.isExecuted = YES;
}


- (MafiaInformation *)endAction {
    return nil;
}


@end  // MafiaAction


@implementation MafiaAssassinAction : MafiaAction


- (MafiaRole *)role {
    return [MafiaRole assassin];
}


- (MafiaNumberRange *)numberOfChoices {
    return [MafiaNumberRange numberRangeWithMinValue:0 maxValue:1];
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


@end  // MafiaAssassinAction


@implementation MafiaGuardianAction


- (MafiaRole *)role {
    return [MafiaRole guardian];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    return (!player.isDead && !player.isUnguardable);
}


@end  // MafiaGuardianAction


@implementation MafiaKillerAction


- (MafiaRole *)role {
    return [MafiaRole killer];
}


@end  // MafiaKillerAction


@implementation MafiaDetectiveAction


- (MafiaRole *)role {
    return [MafiaRole detective];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    // Detective can check any non-detective player, even if he's dead.
    return (![player.role isEqualToRole:self.role]);
}


- (MafiaInformation *)endAction {
    NSArray *selectedPlayers = [self.playerList alivePlayersSelectedBy:self.role];
    BOOL isPositive = NO;
    for (MafiaPlayer *player in selectedPlayers) {
        if ([player.role isEqualToRole:[MafiaRole killer]]) {
            isPositive = YES;
        }
    }
    return [MafiaInformation thumbInformationWithIndicator:isPositive];
}


@end  // MafiaDetectiveAction


@implementation MafiaDoctorAction


- (MafiaRole *)role {
    return [MafiaRole doctor];
}


@end  // MafiaDoctorAction


@implementation MafiaTraitorAction


- (MafiaRole *)role {
    return [MafiaRole traitor];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    // Traitor can check any non-traitor player, even if he's dead.
    return (![player.role isEqualToRole:self.role]);
}


- (MafiaInformation *)endAction {
    NSArray *selectedPlayers = [self.playerList alivePlayersSelectedBy:self.role];
    BOOL isPositive = NO;
    for (MafiaPlayer *player in selectedPlayers) {
        if ([player.role isEqualToRole:[MafiaRole killer]] || [player.role isEqualToRole:[MafiaRole assassin]]) {
            isPositive = YES;
        }
    }
    return [MafiaInformation thumbInformationWithIndicator:isPositive];
}


@end  // MafiaTraitorAction


@implementation MafiaUndercoverAction : MafiaAction


- (MafiaRole *)role {
    return [MafiaRole undercover];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    // Undercover can check any non-undercover player, even if he's dead.
    return (![player.role isEqualToRole:self.role]);
}


- (MafiaInformation *)endAction {
    NSArray *introspectedPlayers = [self.playerList alivePlayersSelectedBy:self.role];
    BOOL isPositive = NO;
    for (MafiaPlayer *player in introspectedPlayers) {
        if ([player.role isEqualToRole:[MafiaRole killer]] || [player.role isEqualToRole:[MafiaRole assassin]]) {
            isPositive = YES;
        }
    }
    return [MafiaInformation thumbInformationWithIndicator:isPositive];
}


@end  // MafiaUndercoverAction
