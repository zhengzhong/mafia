//
//  Created by ZHENG Zhong on 2015-04-11.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaGame;


@protocol MafiaAutonomicActionDelegate <NSObject>

- (void)autonomicActionControllerDidCompleteAction:(UIViewController *)controller;

@end


@protocol MafiaAutonomicAction <NSObject>

@property (weak, nonatomic) id<MafiaAutonomicActionDelegate> delegate;

- (void)setupWithGame:(MafiaGame *)game;

@end
