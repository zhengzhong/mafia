//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MafiaAction;
@class MafiaGameSetup;
@class MafiaPlayer;
@class MafiaPlayerList;


@interface MafiaGame : NSObject

@property (readonly, retain, nonatomic) MafiaPlayerList *playerList;
@property (readonly, retain, nonatomic) NSArray *actions;
@property (assign, nonatomic) NSInteger round;
@property (assign, nonatomic) NSInteger actionIndex;
@property (copy, nonatomic) NSString *winner;

- (id)initWithGameSetup:(MafiaGameSetup *)gameSetup;

- (id)initWithPlayerNames:(NSArray *)playerNames isTwoHanded:(BOOL)isTwoHanded;

- (void)reset;

- (BOOL)checkGameOver;

- (MafiaAction *)currentAction;

- (MafiaAction *)continueToNextAction;

@end // MafiaGame

