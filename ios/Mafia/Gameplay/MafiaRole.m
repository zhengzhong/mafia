//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaRole.h"


@implementation MafiaRole


#pragma mark - Factory Methods


+ (instancetype)civilian {
    return [[self alloc] initWithName:@"civilian"
                          displayName:NSLocalizedString(@"Civilian", nil)
                            alignment:1];
}


+ (instancetype)assassin {
    return [[self alloc] initWithName:@"assassin"
                          displayName:NSLocalizedString(@"Assassin", nil)
                            alignment:-3];
}


+ (instancetype)guardian {
    return [[self alloc] initWithName:@"guardian"
                          displayName:NSLocalizedString(@"Guardian", nil)
                            alignment:1];
}


+ (instancetype)killer {
    return [[self alloc] initWithName:@"killer"
                          displayName:NSLocalizedString(@"Killer", nil)
                            alignment:-3];
}


+ (instancetype)detective {
    return [[self alloc] initWithName:@"detective"
                          displayName:NSLocalizedString(@"Detective", nil)
                            alignment:3];
}


+ (instancetype)doctor {
    return [[self alloc] initWithName:@"doctor"
                          displayName:NSLocalizedString(@"Doctor", nil)
                            alignment:1];
}


+ (instancetype)traitor {
    return [[self alloc] initWithName:@"traitor"
                          displayName:NSLocalizedString(@"Traitor", nil)
                            alignment:-2];
}


+ (instancetype)undercover {
    return [[self alloc] initWithName:@"undercover"
                          displayName:NSLocalizedString(@"Undercover", nil)
                            alignment:3];
}


+ (instancetype)roleWithName:(NSString *)name {
    for (MafiaRole *role in [self roles]) {
        if ([role.name isEqualToString:name]) {
            return role;
        }
    }
    return nil;
}


+ (NSArray *)roles {
    return @[
        [self civilian],
        [self assassin],
        [self guardian],
        [self killer],
        [self detective],
        [self doctor],
        [self traitor],
        [self undercover]
    ];
}


#pragma mark - Init


- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Unavailable"
                                 userInfo:nil];
}


- (instancetype)initWithName:(NSString *)name
                 displayName:(NSString *)displayName
                   alignment:(NSInteger)alignment {
    if (self = [super init]) {
        _name = [name copy];
        _displayName = [displayName copy];
        _alignment = alignment;
    }
    return self;
}


#pragma mark - Equality and Hash


- (BOOL)isEqualToRole:(MafiaRole *)otherRole {
    if (self == otherRole) {
        return YES;
    }
    return [self.name isEqualToString:otherRole.name];
}


- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (other == nil || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToRole:other];
}


- (NSUInteger)hash {
    return [self.name hash];
}


#pragma mark - NSCopying


- (id)copyWithZone:(NSZone *)zone {
    return [[MafiaRole allocWithZone:zone] initWithName:self.name
                                            displayName:self.displayName
                                              alignment:self.alignment];
}


#pragma mark - NSObject


- (NSString *)description {
    return self.displayName;
}


@end
