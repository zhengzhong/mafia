//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaRole.h"


@implementation MafiaRole


#pragma mark - Factory Methods


+ (instancetype)unrevealed {
    static MafiaRole *unrevealed = nil;
    if (unrevealed == nil) {
        unrevealed = [[self alloc] initWithName:@"unrevealed"
                                    displayName:NSLocalizedString(@"Unrevealed", nil)
                                      alignment:0];
    }
    return unrevealed;
}


+ (instancetype)civilian {
    static MafiaRole *civilian = nil;
    if (civilian == nil) {
        civilian = [[self alloc] initWithName:@"civilian"
                                  displayName:NSLocalizedString(@"Civilian", nil)
                                    alignment:1];
    }
    return civilian;
}


+ (instancetype)assassin {
    static MafiaRole *assassin = nil;
    if (assassin == nil) {
        assassin = [[self alloc] initWithName:@"assassin"
                                  displayName:NSLocalizedString(@"Assassin", nil)
                                    alignment:-3];
    }
    return assassin;
}


+ (instancetype)guardian {
    static MafiaRole *guardian = nil;
    if (guardian == nil) {
        guardian = [[self alloc] initWithName:@"guardian"
                                  displayName:NSLocalizedString(@"Guardian", nil)
                                    alignment:1];
    }
    return guardian;
}


+ (instancetype)killer {
    static MafiaRole *killer = nil;
    if (killer == nil) {
        killer = [[self alloc] initWithName:@"killer"
                                displayName:NSLocalizedString(@"Killer", nil)
                                  alignment:-3];
    }
    return killer;
}


+ (instancetype)detective {
    static MafiaRole *detective = nil;
    if (detective == nil) {
        detective = [[self alloc] initWithName:@"detective"
                                   displayName:NSLocalizedString(@"Detective", nil)
                                     alignment:3];
    }
    return detective;
}


+ (instancetype)doctor {
    static MafiaRole *doctor = nil;
    if (doctor == nil) {
        doctor = [[self alloc] initWithName:@"doctor"
                                displayName:NSLocalizedString(@"Doctor", nil)
                                  alignment:1];
    }
    return doctor;
}


+ (instancetype)traitor {
    static MafiaRole *traitor = nil;
    if (traitor == nil) {
        traitor = [[self alloc] initWithName:@"traitor"
                                 displayName:NSLocalizedString(@"Traitor", nil)
                                   alignment:-2];
    }
    return traitor;
}


+ (instancetype)undercover {
    static MafiaRole *undercover = nil;
    if (undercover == nil) {
        undercover = [[self alloc] initWithName:@"undercover"
                                    displayName:NSLocalizedString(@"Undercover", nil)
                                      alignment:-3];
    }
    return undercover;
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


#pragma mark - Initializer


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


#pragma mark - Equality


- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (other == nil || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToRole:other];
}


- (BOOL)isEqualToRole:(MafiaRole *)otherRole {
    if (self == otherRole) {
        return YES;
    }
    return [self.name isEqualToString:otherRole.name];
}


#pragma mark - NSObject


- (NSString *)description {
    return self.displayName;
}


@end  // MafiaRole
