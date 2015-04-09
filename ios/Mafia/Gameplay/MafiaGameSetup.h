//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MafiaRole;

@interface MafiaGameSetup : NSObject

/// An array of player names.
@property (readonly, strong, nonatomic) NSMutableArray *playerNames;

/// Whether the game is using two-handed mode.
@property (assign, nonatomic) BOOL isTwoHanded;

/// Settings of roles: key is the role, value is the number of actors for the role.
@property (readonly, strong, nonatomic) NSMutableDictionary *roleSettings;

- (void)addPlayerName:(NSString *)playerName;

- (NSInteger)numberOfActorsForRole:(MafiaRole *)role;

- (void)setNumberOfActors:(NSInteger)numberOfActors forRole:(MafiaRole *)role;

- (NSInteger)numberOfPlayersRequired;

- (BOOL)isValid;

@end
