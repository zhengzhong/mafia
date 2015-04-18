//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaAction;
@class MafiaGame;


@interface MafiaAutonomicGameActionCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *actionImageView;
@property (strong, nonatomic) IBOutlet UILabel *actionNameLabel;

- (void)setupWithAction:(MafiaAction *)action isCurrent:(BOOL)isCurrent;

@end


@interface MafiaAutonomicGameController : UITableViewController

@property (strong, nonatomic) MafiaGame *game;

- (void)startGame:(MafiaGame *)game;

- (IBAction)resetButtonTapped:(id)sender;

@end
