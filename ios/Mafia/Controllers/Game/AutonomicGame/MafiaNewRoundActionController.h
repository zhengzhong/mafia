//
//  Created by ZHENG Zhong on 2016-11-30.
//  Copyright (c) 2016 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MafiaAutonomicAction.h"

@class MafiaGame;


@interface MafiaNewRoundActionController : UIViewController <MafiaAutonomicAction>

@property (strong, nonatomic) MafiaGame *game;
@property (assign, nonatomic) BOOL isStarted;
@property (weak, nonatomic) id<MafiaAutonomicActionDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIButton *startDoneButton;

- (IBAction)startDoneButtonTapped:(id)sender;

- (void)setupWithGame:(MafiaGame *)game;

@end
