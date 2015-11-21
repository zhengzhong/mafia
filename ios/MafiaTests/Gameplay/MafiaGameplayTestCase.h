//
//  Created by ZHENG Zhong on 2012-12-06.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <XCTest/XCTest.h>


@class MafiaPlayer;
@class MafiaPlayerList;


@interface MafiaGameplayTestCase : XCTestCase

@property (strong, nonatomic) MafiaPlayerList *playerList;
@property (strong, nonatomic) MafiaPlayer *assassin;
@property (strong, nonatomic) MafiaPlayer *killer1;
@property (strong, nonatomic) MafiaPlayer *killer2;
@property (strong, nonatomic) MafiaPlayer *detective1;
@property (strong, nonatomic) MafiaPlayer *detective2;
@property (strong, nonatomic) MafiaPlayer *guardian;
@property (strong, nonatomic) MafiaPlayer *doctor;
@property (strong, nonatomic) MafiaPlayer *traitor;
@property (strong, nonatomic) MafiaPlayer *undercover;

- (void)resetPlayerListAndAssignRoles;

@end  // MafiaGameplayTestCase
