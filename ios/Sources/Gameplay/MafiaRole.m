//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaRole.h"

@implementation MafiaRole


@synthesize name = _name;
@synthesize displayName = _displayName;
@synthesize alignment = _alignment;




- (id)initWithName:(NSString *)name displayName:(NSString *)displayName alignment:(NSInteger)alignment
{
    if (self = [super init])
    {
        _name = [name copy];
        _displayName = [displayName copy];
        _alignment = alignment;
    }
    return self;
}


- (NSString *)description
{
    return self.displayName;
}


+ (MafiaRole *)unrevealed
{
    static MafiaRole *Unrevealed = nil;
    if (Unrevealed == nil)
    {
        Unrevealed = [[self alloc] initWithName:@"unrevealed" displayName:NSLocalizedString(@"Unrevealed", nil) alignment:0];
    }
    return Unrevealed;
}


+ (MafiaRole *)civilian
{
    static MafiaRole *Civilian = nil;
    if (Civilian == nil)
    {
        Civilian = [[self alloc] initWithName:@"civilian" displayName:NSLocalizedString(@"Civilian", nil) alignment:1];
    }
    return Civilian;
}


+ (MafiaRole *)assassin
{
    static MafiaRole *Assassin = nil;
    if (Assassin == nil)
    {
        Assassin = [[self alloc] initWithName:@"assassin" displayName:NSLocalizedString(@"Assassin", nil) alignment:-3];
    }
    return Assassin;
}


+ (MafiaRole *)guardian;
{
    static MafiaRole *Guardian = nil;
    if (Guardian == nil)
    {
        Guardian = [[self alloc] initWithName:@"guardian" displayName:NSLocalizedString(@"Guardian", nil) alignment:1];
    }
    return Guardian;
}


+ (MafiaRole *)killer
{
    static MafiaRole *Killer = nil;
    if (Killer == nil)
    {
        Killer = [[self alloc] initWithName:@"killer" displayName:NSLocalizedString(@"Killer", nil) alignment:-3];
    }
    return Killer;
}


+ (MafiaRole *)detective
{
    static MafiaRole *Detective = nil;
    if (Detective == nil)
    {
        Detective = [[self alloc] initWithName:@"detective" displayName:NSLocalizedString(@"Detective", nil) alignment:3];
    }
    return Detective;
}


+ (MafiaRole *)doctor
{
    static MafiaRole *Doctor = nil;
    if (Doctor == nil)
    {
        Doctor = [[self alloc] initWithName:@"doctor" displayName:NSLocalizedString(@"Doctor", nil) alignment:1];
    }
    return Doctor;
}


+ (MafiaRole *)traitor
{
    static MafiaRole *Traitor = nil;
    if (Traitor == nil)
    {
        Traitor = [[self alloc] initWithName:@"traitor" displayName:NSLocalizedString(@"Traitor", nil) alignment:-2];
    }
    return Traitor;
}


+ (MafiaRole *)undercover
{
    static MafiaRole *Undercover = nil;
    if (Undercover == nil)
    {
        Undercover = [[self alloc] initWithName:@"undercover" displayName:NSLocalizedString(@"Undercover", nil) alignment:-3];
    }
    return Undercover;
}


+ (NSArray *)roles
{
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


@end // MafiaRole

