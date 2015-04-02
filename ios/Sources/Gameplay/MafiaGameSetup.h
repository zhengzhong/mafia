//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MafiaGameSetup : NSObject

@property (readonly, strong, nonatomic) NSMutableArray *playerNames;
@property (assign, nonatomic) BOOL isTwoHanded;
@property (assign, nonatomic) NSInteger numberOfKillers;
@property (assign, nonatomic) NSInteger numberOfDetectives;
@property (assign, nonatomic) BOOL hasAssassin;
@property (assign, nonatomic) BOOL hasGuardian;
@property (assign, nonatomic) BOOL hasDoctor;
@property (assign, nonatomic) BOOL hasTraitor;
@property (assign, nonatomic) BOOL hasUndercover;

- (void)addPlayerName:(NSString *)playerName;

- (NSInteger)numberOfPlayersRequired;

- (BOOL)isValid;

@end  // MafiaGameSetup
