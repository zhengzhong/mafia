//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MafiaRole;


@interface MafiaPlayer : NSObject

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) MafiaRole *role;
@property (assign, nonatomic) BOOL isDead;
@property (assign, nonatomic) BOOL isMisdiagnosed;
@property (assign, nonatomic) BOOL isJustGuarded;
@property (assign, nonatomic) BOOL isUnguardable;
@property (assign, nonatomic) BOOL isVoted;
@property (strong, nonatomic) NSMutableArray *tags;

@property (readonly, assign, nonatomic) BOOL isUnrevealed;

+ (instancetype)playerWithName:(NSString *)name;

- (instancetype)initWithName:(NSString *)name;

- (void)reset;

- (void)prepareToStart;

- (void)selectByRole:(MafiaRole *)role;

- (void)unselectFromRole:(MafiaRole *)role;

- (BOOL)isSelectedByRole:(MafiaRole *)role;

- (void)lynch;

/*!
 * Marks the player as dead, and removes all the tags attached on him.
 * Note: the status flags on the player are not changed.
 */
- (void)markDead;

@end  // MafiaPlayer
