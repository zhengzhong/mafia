//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetup.h"
#import "MafiaRole.h"


@implementation MafiaGameSetup


- (instancetype)init {
    if (self = [super init]) {
        _persons = [NSMutableArray arrayWithCapacity:20];
        _isTwoHanded = YES;
        _isAutonomic = NO;
        _roleSettings = [@{
            [MafiaRole killer]: @2,
            [MafiaRole detective]: @2,
            [MafiaRole assassin]: @0,
            [MafiaRole guardian]: @1,
            [MafiaRole doctor]: @1,
            [MafiaRole traitor]: @1,
            [MafiaRole undercover]: @0,
        } mutableCopy];
    }
    return self;
}


- (void)addPerson:(MafiaPerson *)person {
    if (person != nil && ![self.persons containsObject:person]) {
        [self.persons addObject:person];
    }
}


- (NSInteger)numberOfActorsForRole:(MafiaRole *)role {
    return [self.roleSettings[role] intValue];
}


- (void)setNumberOfActors:(NSInteger)numberOfActors forRole:(MafiaRole *)role {
    self.roleSettings[role] = @(numberOfActors);
}


- (NSInteger)numberOfPersonsRequired {
    NSInteger numberOfRoles = 0;
    for (MafiaRole *role in self.roleSettings) {
        numberOfRoles += [self.roleSettings[role] intValue];
    }
    return (NSInteger)ceil(numberOfRoles * (self.isTwoHanded ? 0.7 : 1.4));
}


- (BOOL)isValid {
    return ([self.persons count] >= [self numberOfPersonsRequired]);
}


@end
