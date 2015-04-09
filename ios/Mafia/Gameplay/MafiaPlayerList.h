//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MafiaRole;
@class MafiaPlayer;


@interface MafiaPlayerList : NSObject <NSFastEnumeration>

@property (readonly, copy, nonatomic) NSArray *players;

/*!
 * Initializes the player list.
 * @param playerNames  an array of player names.
 * @param isTwoHanded  whether the game is in two-handed mode. If yes, for each player name, two
 *                     players will be added (for left hand and right hand, respectively).
 */
- (instancetype)initWithPlayerNames:(NSArray *)playerNames isTwoHanded:(BOOL)isTwoHanded
    NS_DESIGNATED_INITIALIZER;

- (NSUInteger)count;

- (MafiaPlayer *)playerAtIndex:(NSUInteger)index;

- (MafiaPlayer *)playerNamed:(NSString *)name;

- (NSArray *)alivePlayers;

- (NSArray *)alivePlayersWithRole:(MafiaRole *)role;

- (NSArray *)alivePlayersSelectedBy:(MafiaRole *)selectorRole;

- (NSArray *)alivePlayersWithRole:(MafiaRole *)role selectedBy:(MafiaRole *)selectorRole;

- (void)reset;

- (void)prepareToStart;

@end
