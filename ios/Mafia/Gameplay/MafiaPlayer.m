//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaPlayer.h"
#import "MafiaPerson.h"
#import "MafiaRole.h"


@implementation MafiaPlayer


#pragma mark - Factory Method and Initializer


+ (instancetype)playerWithPerson:(MafiaPerson *)person handSide:(MafiaHandSide)handSide {
    return [[self alloc] initWithPerson:person handSide:handSide];
}


- (instancetype)initWithPerson:(MafiaPerson *)person handSide:(MafiaHandSide)handSide {
    if (self = [super init]) {
        _person = person;
        _handSide = handSide;
        _role = nil;
        _previousRoleTags = [[NSMutableSet alloc] initWithCapacity:10];
        _currentRoleTags = [[NSMutableSet alloc] initWithCapacity:10];
    }
    return self;
}


#pragma mark - Properties


@dynamic name;

- (NSString *)name {
    return self.person.name;
}


@dynamic avatarImage;

- (UIImage *)avatarImage {
    return self.person.avatarImage;
}


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
        return self.person.name;
    } else {
        return [NSString stringWithFormat:@"%@:%@", self.person.name, handSideString];
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


- (void)updatePreviousRoleTags {
    [self.previousRoleTags unionSet:self.currentRoleTags];
}


- (void)clearSelectionTagByRole:(MafiaRole *)role {
    if ([self.currentRoleTags containsObject:role]) {
        [self.currentRoleTags removeObject:role];
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
