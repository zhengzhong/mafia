//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaPlayer.h"
#import "MafiaRole.h"


@implementation MafiaPlayer


#pragma mark - Properties


@dynamic isUnrevealed;

- (BOOL)isUnrevealed {
    return [self.role isEqualToRole:[MafiaRole unrevealed]];
}


#pragma mark - Factory Method and Initializer


+ (instancetype)playerWithName:(NSString *)name {
    return [[self alloc] initWithName:name];
}


- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        _name = [name copy];
        _role = [MafiaRole unrevealed];
        _tags = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return self;
}


#pragma mark - Public


- (void)reset {
    self.role = [MafiaRole unrevealed];
    [self prepareToStart];
}


- (void)prepareToStart {
    self.isDead = NO;
    self.isMisdiagnosed = NO;
    self.isJustGuarded = NO;
    self.isUnguardable = NO;
    self.isVoted = NO;
    [self.tags removeAllObjects];
}


- (void)selectByRole:(MafiaRole *)role {
    [self.tags addObject:role];
}


- (void)unselectFromRole:(MafiaRole *)role {
    [self.tags removeObject:role];
}


- (BOOL)isSelectedByRole:(MafiaRole *)role {
    return [self.tags containsObject:role];
}


- (void)lynch {
    if (!self.isJustGuarded) {
        [self markDead];
    }
}


- (void)markDead {
    self.isDead = YES;
    [self.tags removeAllObjects];
}


#pragma mark - NSObject


- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.role.displayName, self.name];
}


@end  // MafiaPlayer
