//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaPlayer.h"
#import "MafiaRole.h"


@implementation MafiaPlayer


#pragma mark - Factory Method and Initializer


+ (instancetype)playerWithName:(NSString *)name handSide:(MafiaHandSide)handSide {
    return [[self alloc] initWithName:name handSide:handSide];
}


- (instancetype)initWithName:(NSString *)name handSide:(MafiaHandSide)handSide {
    if (self = [super init]) {
        _name = [name copy];
        _handSide = handSide;
        _role = nil;
        _previousRoleTags = [[NSMutableSet alloc] initWithCapacity:10];
        _currentRoleTags = [[NSMutableSet alloc] initWithCapacity:10];
    }
    return self;
}


#pragma mark - Properties


@dynamic displayName;

- (NSString *)displayName {
    NSString *handSideString = nil;
    switch (self.handSide) {
        case MafiaHandSideBoth:
            handSideString = nil;
            break;
        case MafiaHandSideLeft:
            handSideString = NSLocalizedString(@"Left", nil);
            break;
        case MafiaHandSideRight:
            handSideString = NSLocalizedString(@"Right", nil);
            break;
    }
    if (handSideString == nil) {
        return self.name;
    } else {
        return [NSString stringWithFormat:@"%@:%@", self.name, handSideString];
    }
}


#pragma mark - Public


- (void)reset {
    self.role = nil;
    [self prepareToStart];
}


- (void)prepareToStart {
    self.isDead = NO;
    self.isMisdiagnosed = NO;
    self.isJustGuarded = NO;
    self.isUnguardable = NO;
    self.isVoted = NO;
    [self.previousRoleTags removeAllObjects];
    [self.currentRoleTags removeAllObjects];
}


- (void)selectByRole:(MafiaRole *)role {
    [self.currentRoleTags addObject:role];
}


- (void)clearSelectionTagByRole:(MafiaRole *)role {
    if ([self.currentRoleTags containsObject:role]) {
        [self.currentRoleTags removeObject:role];
        [self.previousRoleTags addObject:role];
    }
}


- (BOOL)isSelectedByRole:(MafiaRole *)role {
    return [self.currentRoleTags containsObject:role];
}


- (BOOL)wasSelectedByRole:(MafiaRole *)role {
    return [self.previousRoleTags containsObject:role];
}


- (void)lynch {
    if (!self.isJustGuarded) {
        [self markDead];
    }
}


- (void)markDead {
    self.isDead = YES;
    [self.currentRoleTags removeAllObjects];
}


#pragma mark - NSObject


- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@)", self.displayName, self.role.displayName];
}


@end  // MafiaPlayer
