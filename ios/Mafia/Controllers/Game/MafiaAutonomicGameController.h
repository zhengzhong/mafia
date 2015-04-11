//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaGame;

@interface MafiaAutonomicGameController : UITableViewController

@property (strong, nonatomic) MafiaGame *game;

- (void)startGame:(MafiaGame *)game;

- (IBAction)resetButtonTapped:(id)sender;

@end
