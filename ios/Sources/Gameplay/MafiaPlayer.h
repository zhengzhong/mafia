//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MafiaRole;


@interface MafiaPlayer : NSObject

@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) MafiaRole *role;
@property (assign, nonatomic) BOOL isDead;
@property (assign, nonatomic) BOOL isMisdiagnosed;
@property (assign, nonatomic) BOOL isJustGuarded;
@property (assign, nonatomic) BOOL isUnguardable;
@property (assign, nonatomic) BOOL isVoted;
@property (retain, nonatomic) NSMutableArray *tags;

- (id)initWithName:(NSString *)name;

+ (id)playerWithName:(NSString *)name;

- (void)reset;

- (BOOL)isUnrevealed;

- (void)selectByRole:(MafiaRole *)role;

- (void)unselectFromRole:(MafiaRole *)role;

- (BOOL)isSelectedByRole:(MafiaRole *)role;

- (void)lynch;

- (void)markDead;

@end

