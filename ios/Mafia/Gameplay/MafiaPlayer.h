//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MafiaRole;


/*!
 * This class represents a player in the game. Note: in two-handed mode, a real person
 * participating the game has 2 players, one for each hand side.
 */
@interface MafiaPlayer : NSObject

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) MafiaRole *role;
@property (assign, nonatomic) BOOL isDead;
@property (assign, nonatomic) BOOL isMisdiagnosed;
@property (assign, nonatomic) BOOL isJustGuarded;
@property (assign, nonatomic) BOOL isUnguardable;
@property (assign, nonatomic) BOOL isVoted;

/// A set of roles, indicating that in previous rounds, which roles have selected this player.
@property (strong, nonatomic) NSMutableSet *previousRoleTags;

/// A set of roles, indicating that in the current round, which roles have selected this player.
@property (strong, nonatomic) NSMutableSet *currentRoleTags;

@property (readonly, assign, nonatomic) BOOL isUnrevealed;

+ (instancetype)playerWithName:(NSString *)name;

- (instancetype)initWithName:(NSString *)name;

/*!
 * Resets properties of this player, including his role.
 */
- (void)reset;

/*!
 * This method is called when the game starts. It resets the player's properties to initial states.
 */
- (void)prepareToStart;

/*!
 * This method is called when the player is selected by the given role in the current round.
 */
- (void)selectByRole:(MafiaRole *)role;

/*!
 * Clears the selection tag from the given role for the current round.
 */
- (void)clearSelectionTagByRole:(MafiaRole *)role;

/*!
 * Checks if in the current round, the player is selected by the given role.
 */
- (BOOL)isSelectedByRole:(MafiaRole *)role;

/*!
 * Checks if in previous rounds, the player was selected by the given role.
 */
- (BOOL)wasSelectedByRole:(MafiaRole *)role;

- (void)lynch;

/*!
 * Marks the player as dead, and removes all the tags attached on him.
 * Note: the status flags on the player are not changed.
 */
- (void)markDead;

@end  // MafiaPlayer
