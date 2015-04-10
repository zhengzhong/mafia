//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MafiaInformation;
@class MafiaNumberRange;
@class MafiaPlayer;
@class MafiaPlayerList;
@class MafiaRole;


FOUNDATION_EXPORT NSString *const MafiaInvalidActionRoleException;


/*!
 * Abstract base class for an action that can be taken by a certain role.
 */
@interface MafiaAction : NSObject

/// The role of this action, nil by default. Subclass may override getter of this property.
@property (readonly, strong, nonatomic) MafiaRole *role;

/// The player of this action in autonomic mode, or nil.
@property (readonly, strong, nonatomic) MafiaPlayer *player;

/// A list of all the players of the game.
@property (readonly, strong, nonatomic) MafiaPlayerList *playerList;

/// Whether this action has been executed (in the current round).
@property (assign, nonatomic) BOOL isExecuted;

/*!
 * Initializes an action. The given role must match the action subclass.
 * @param role  the role of this action, must match the action subclass.
 * @param player  the player of this action (in autonomic mode) or nil.
 * @param playerList  the player list of the game.
 */
- (instancetype)initWithRole:(MafiaRole *)role
                      player:(MafiaPlayer *)player
                  playerList:(MafiaPlayerList *)playerList
    NS_DESIGNATED_INITIALIZER;

/*!
 * Returns an array of actors of this action who are still alive. By default, if this action is not
 * associated to a player, this method returns all alive players whose role is the action's role.
 * If the action is associated to a player, this method returns that player if he's alive, or an
 * empty array if he's dead.
 */
- (NSArray *)actors;

/*!
 * Checks if the action is executable. Note that for a non-executable action, in its turn, the
 * `beginAction` and `endAction` methods should still be called, but its `executeOnPlayer:` method
 * should not be called. By default, an action is executable if there exists at least one actor.
 */
- (BOOL)isExecutable;

/*!
 * Returns the number of choices (players) this action can be executed on. By default, an action
 * can be executed on 1 player.
 */
- (MafiaNumberRange *)numberOfChoices;

/*!
 * Checks if the given player can be selected by this action. By default, a player is selectable
 * if he is alive.
 */
- (BOOL)isPlayerSelectable:(MafiaPlayer *)player;

/*!
 * This method is called before the action is executed. It marks the action as non-executed.
 */
- (void)beginAction;

/*!
 * Executes the action on the given player. The action must be in non-executed state, and the given
 * player must be selectable by this action. By default, this method marks the given player as
 * selected by the action's role. After this method is called, the action is marked as executed.
 */
- (void)executeOnPlayer:(MafiaPlayer *)player;

/*!
 * This method is called after the action is executed. It may return information about the
 * execution result, or nil, as appropriate. By default, it does nothing and returns nil.
 */
- (MafiaInformation *)endAction;

@end
