//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MafiaRole;


typedef NS_ENUM(NSInteger, MafiaHandSide) {
    MafiaHandSideBoth,
    MafiaHandSideLeft,
    MafiaHandSideRight,
};


/*!
 * This class represents a player in the game. Note: in two-handed mode, a real person
 * participating the game has 2 players, one for each hand side.
 */
@interface MafiaPlayer : NSObject

/// The name of the person who controls this player.
@property (readonly, copy, nonatomic) NSString *name;

/// The hand side of the person who controls this player.
@property (readonly, assign, nonatomic) MafiaHandSide handSide;

/// The display name of this player, composed by name and hand side.
@property (readonly, copy, nonatomic) NSString *displayName;

/// The role assigned to this player.
@property (copy, nonatomic) MafiaRole *role;

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

+ (instancetype)playerWithName:(NSString *)name handSide:(MafiaHandSide)handSide;

- (instancetype)initWithName:(NSString *)name handSide:(MafiaHandSide)handSide
    NS_DESIGNATED_INITIALIZER;

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
