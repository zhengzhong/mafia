//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Mantle/Mantle.h"

@class MafiaPerson;
@class MafiaRole;

@interface MafiaGameSetup : MTLModel <MTLJSONSerializing>

/// An array of persons.
@property (readonly, strong, nonatomic) NSMutableArray *persons;

/// Whether the game is using two-handed mode.
@property (assign, nonatomic) BOOL isTwoHanded;

/// Whether the game will be in autonomic mode (no judge).
@property (assign, nonatomic) BOOL isAutonomic;

/// Settings of roles: key is the role, value is the number of actors for the role.
@property (readonly, strong, nonatomic) NSMutableDictionary *roleSettings;

- (void)addPerson:(MafiaPerson *)person;

- (NSInteger)numberOfActorsForRole:(MafiaRole *)role;

- (void)setNumberOfActors:(NSInteger)numberOfActors forRole:(MafiaRole *)role;

- (NSInteger)numberOfPersonsRequired;

- (BOOL)isValid;

- (BOOL)saveWithName:(NSString *)name;

- (BOOL)saveToRecent;

+ (instancetype)loadWithName:(NSString *)name;

+ (instancetype)loadFromRecent;

@end
