//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MafiaAction;
@class MafiaGameSetup;
@class MafiaPlayer;
@class MafiaPlayerList;
@class MafiaRole;


typedef NS_ENUM(NSInteger, MafiaWinner) {
    MafiaWinnerUnknown,
    MafiaWinnerCivilians,
    MafiaWinnerKillers,
};


@interface MafiaGame : NSObject

@property (readonly, strong, nonatomic) MafiaGameSetup *gameSetup;
@property (readonly, strong, nonatomic) MafiaPlayerList *playerList;
@property (readonly, copy, nonatomic) NSMutableArray *actions;
@property (readonly, assign, nonatomic) NSInteger round;
@property (readonly, assign, nonatomic) NSInteger actionIndex;
@property (readonly, assign, nonatomic) MafiaWinner winner;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithPersons:(NSArray *)persons isTwoHanded:(BOOL)isTwoHanded;

- (instancetype)initWithGameSetup:(MafiaGameSetup *)gameSetup NS_DESIGNATED_INITIALIZER;

- (void)reset;

- (BOOL)checkGameOver;

- (void)assignRole:(MafiaRole *)role toPlayers:(NSArray *)players;

- (void)assignCivilianRoleToUnassignedPlayers;

- (void)assignRolesRandomly;

- (BOOL)isReadyToStart;

- (void)startGame;

- (MafiaAction *)currentAction;

- (MafiaAction *)continueToNextAction;

@end
