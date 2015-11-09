//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MafiaPlayer.h"

@class MafiaRole;


@interface MafiaPlayerList : NSObject <NSFastEnumeration>

@property (readonly, copy, nonatomic) NSArray *players;

- (instancetype)init NS_UNAVAILABLE;

/*!
 * Initializes the player list.
 * @param persons  an array of persons.
 * @param isTwoHanded  whether the game is in two-handed mode. If yes, for each person, two players
 *                     will be added (for left hand and right hand, respectively).
 */
- (instancetype)initWithPersons:(NSArray *)persons isTwoHanded:(BOOL)isTwoHanded
    NS_DESIGNATED_INITIALIZER;

/*!
 * Returns the number of players.
 */
- (NSUInteger)count;

/*!
 * Returns a player at the given index.
 */
- (MafiaPlayer *)playerAtIndex:(NSUInteger)index;

/*!
 * Returns a player by given name and hand side.
 */
- (MafiaPlayer *)playerWithName:(NSString *)name handSide:(MafiaHandSide)handSide;

/*!
 * Returns the twin player of the given player. In two-handed mode, the returned player is the
 * other hand of the given player. In non-two-handed mode, this method returns nil.
 * @param player  the player with whom the twin player is searched.
 */
- (MafiaPlayer *)twinOfPlayer:(MafiaPlayer *)player;

/*!
 * Returns an array of alive players.
 */
- (NSArray *)alivePlayers;

/*!
 * Returns an array of players whose role is the given role.
 * @param role  the role used to filter players.
 * @param aliveOnly  whether only alive players should be returned.
 */
- (NSArray *)playersWithRole:(MafiaRole *)role aliveOnly:(BOOL)aliveOnly;

/*!
 * Returns an array of players who are selected by the given role in the current round.
 * @param selectedByRole  the role who has selected the players in the current round.
 * @param aliveOnly  whether only alive players should be returned.
 */
- (NSArray *)playersSelectedBy:(MafiaRole *)selectedByRole aliveOnly:(BOOL)aliveOnly;

/*!
 * Returns an array of players that satisfy the given conditions.
 * @param role  the role of the players.
 * @param selectedByRole  the role who selects the players in the current round.
 * @param aliveOnly  whether to return only alive players.
 */
- (NSArray *)playersWithRole:(MafiaRole *)role
                  selectedBy:(MafiaRole *)selectedByRole
                   aliveOnly:(BOOL)aliveOnly;

/*!
 * Resets properties of all the players. Player roles will also be reset.
 */
- (void)reset;

/*!
 * Prepares the players when the game starts, by resetting their properties to initial states.
 */
- (void)prepareToStart;

@end
