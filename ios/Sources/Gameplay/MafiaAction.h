//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MafiaPlayer;
@class MafiaPlayerList;
@class MafiaRole;


@interface MafiaAction : NSObject

@property (readonly, assign, nonatomic) NSInteger numberOfActors;
@property (readonly, retain, nonatomic) MafiaPlayerList *playerList;
@property (assign, nonatomic) BOOL isAssigned;
@property (assign, nonatomic) BOOL isExecuted;

- (id)initWithNumberOfActors:(NSInteger)numberOfActors playerList:(MafiaPlayerList *)playerList;

+ (id)actionWithNumberOfActors:(NSInteger)numberOfActors playerList:(MafiaPlayerList *)playerList;

- (MafiaRole *)role;

- (void)reset;

- (void)assignRoleToPlayers:(NSArray *)players;

- (NSArray *)actors;

- (BOOL)isExecutable;

- (BOOL)isPlayerSelectable:(MafiaPlayer *)player;

- (void)beginAction;

- (void)executeOnPlayer:(MafiaPlayer *)player;

- (NSArray *)endAction;

@end // MafiaAction


@interface MafiaAssassinAction : MafiaAction

@property (assign, nonatomic) BOOL isChanceUsed;

@end // MafiaAssassinAction


@interface MafiaGuardianAction : MafiaAction

@end // MafiaGuardianAction


@interface MafiaKillerAction : MafiaAction

@end // MafiaKillerAction


@interface MafiaDetectiveAction : MafiaAction

@end // MafiaDetectiveAction


@interface MafiaDoctorAction : MafiaAction

@end // MafiaDoctorAction


@interface MafiaTraitorAction : MafiaAction

@end // MafiaTraitorAction


@interface MafiaUndercoverAction : MafiaAction

@end // MafiaUndercoverAction

