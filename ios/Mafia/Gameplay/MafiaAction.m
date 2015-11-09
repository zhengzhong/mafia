//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAction.h"
#import "MafiaNumberRange.h"
#import "MafiaPlayer.h"
#import "MafiaPlayerList.h"
#import "MafiaRole.h"


NSString *const MafiaInvalidActionRoleException = @"MafiaInvalidActionRole";


@implementation MafiaAction


#pragma mark - Init


- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Unavailable"
                                 userInfo:nil];
}


- (instancetype)initWithRole:(MafiaRole *)role
                      player:(MafiaPlayer *)player
                  playerList:(MafiaPlayerList *)playerList {
    if (player != nil) {
        NSAssert([player.role isEqualToRole:role], @"Player and role do not match.");
    }
    if (self = [super init]) {
        _role = role;
        _player = player;
        _playerList = playerList;
        _isExecuted = NO;
    }
    return self;
}


#pragma mark - Properties


@dynamic displayName;

- (NSString *)displayName {
    NSString *prefix = (self.player != nil ? self.player.displayName : self.role.displayName);
    return [NSString stringWithFormat:NSLocalizedString(@"%@ Action", nil), prefix];
}


#pragma mark - Public Methods


- (NSArray *)actors {
    if (self.player != nil) {
        return (self.player.isDead ? @[] : @[self.player]);
    } else {
        return [self.playerList playersWithRole:self.role aliveOnly:YES];
    }
}


- (BOOL)isExecutable {
    return ([[self actors] count] > 0);
}


- (MafiaNumberRange *)numberOfChoices {
    return [MafiaNumberRange numberRangeWithSingleValue:1];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}


- (void)beginAction {
    self.isExecuted = NO;
}


- (void)executeOnPlayer:(MafiaPlayer *)player {
    NSAssert(!self.isExecuted, @"%@ is already executed.", self);
    NSAssert([self isPlayerSelectable:player], @"%@ cannot select %@.", self.role, player);
    self.isExecuted = YES;
}


- (MafiaInformation *)endAction {
    return nil;
}


#pragma mark - NSObject


- (NSString *)description {
    return self.displayName;
}


@end
