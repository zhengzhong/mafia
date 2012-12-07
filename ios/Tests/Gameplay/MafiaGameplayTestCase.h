//
//  Created by ZHENG Zhong on 2012-12-06.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@class MafiaPlayer;
@class MafiaPlayerList;


@interface MafiaGameplayTestCase : SenTestCase

@property (retain, nonatomic) MafiaPlayerList *playerList;
@property (retain, nonatomic) MafiaPlayer *assassin;
@property (retain, nonatomic) MafiaPlayer *killer1;
@property (retain, nonatomic) MafiaPlayer *killer2;
@property (retain, nonatomic) MafiaPlayer *detective1;
@property (retain, nonatomic) MafiaPlayer *detective2;
@property (retain, nonatomic) MafiaPlayer *guardian;
@property (retain, nonatomic) MafiaPlayer *doctor;
@property (retain, nonatomic) MafiaPlayer *traitor;
@property (retain, nonatomic) MafiaPlayer *undercover;

- (void)resetPlayerListAndAssignRoles;

@end // MafiaGameplayTestCase

