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


/*!
 * Abstract base class for an action that can be taken by a certain role.
 */
@interface MafiaAction : NSObject

/// Number of actors of this action.
@property (readonly, assign, nonatomic) NSInteger numberOfActors;

/// A list of all the players of the game.
@property (readonly, strong, nonatomic) MafiaPlayerList *playerList;

/// Whether the role of this action has already been assigned to player(s).
@property (assign, nonatomic) BOOL isAssigned;

/// Whether this action has been executed (in the current round).
@property (assign, nonatomic) BOOL isExecuted;

/// The role of this action.
@property (readonly, strong, nonatomic) MafiaRole *role;

/*!
 * Returns an action instance.
 */
+ (instancetype)actionWithNumberOfActors:(NSInteger)numberOfActors
                              playerList:(MafiaPlayerList *)playerList;

/*!
 * Designated initializer.
 */
- (instancetype)initWithNumberOfActors:(NSInteger)numberOfActors
                            playerList:(MafiaPlayerList *)playerList
    NS_DESIGNATED_INITIALIZER;

/*!
 * Resets status of this action to un-assigned and un-executed.
 */
- (void)reset;

/*!
 * Assigns the role of this action to the given players. Number of players to assign must match
 * the number of actors.
 */
- (void)assignRoleToPlayers:(NSArray *)players;

/*!
 * Returns an array of actors of this action who are still alive.
 */
- (NSArray *)actors;

/*!
 * Checks if the action is executable.
 */
- (BOOL)isExecutable;

/*!
 * Returns the number of choices (players) this action can be executed on.
 */
- (MafiaNumberRange *)numberOfChoices;

/*!
 * Checks if the given player can be selected by this action.
 */
- (BOOL)isPlayerSelectable:(MafiaPlayer *)player;

/*!
 * This method is called before the action is executed.
 */
- (void)beginAction;

/*!
 * Executes the action on the given player.
 */
- (void)executeOnPlayer:(MafiaPlayer *)player;

/*!
 * This method is called after the action is executed. It may return information about the
 * execution result, or nil, as appropriate.
 */
- (MafiaInformation *)endAction;

@end  // MafiaAction


@interface MafiaAssassinAction : MafiaAction

@property (assign, nonatomic) BOOL isChanceUsed;

@end  // MafiaAssassinAction


@interface MafiaGuardianAction : MafiaAction

@end  // MafiaGuardianAction


@interface MafiaKillerAction : MafiaAction

@end  // MafiaKillerAction


@interface MafiaDetectiveAction : MafiaAction

@end  // MafiaDetectiveAction


@interface MafiaDoctorAction : MafiaAction

@end  // MafiaDoctorAction


@interface MafiaTraitorAction : MafiaAction

@end  // MafiaTraitorAction


@interface MafiaUndercoverAction : MafiaAction

@end  // MafiaUndercoverAction
