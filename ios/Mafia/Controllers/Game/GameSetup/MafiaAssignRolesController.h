//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaGame;
@class MafiaGameSetup;
@class MafiaPlayer;


@interface MafiaTwoPlayersCell : UITableViewCell

@property (strong, nonatomic) MafiaPlayer *player1;
@property (strong, nonatomic) MafiaPlayer *player2;
@property (assign, nonatomic) BOOL isPlayer1Revealed;
@property (assign, nonatomic) BOOL isPlayer2Revealed;

@property (strong, nonatomic) IBOutlet UIButton *player1Button;
@property (strong, nonatomic) IBOutlet UIImageView *player1ImageView;
@property (strong, nonatomic) IBOutlet UILabel *player1Label;
@property (strong, nonatomic) IBOutlet UIButton *player2Button;
@property (strong, nonatomic) IBOutlet UIImageView *player2ImageView;
@property (strong, nonatomic) IBOutlet UILabel *player2Label;

- (void)setupWithPlayer:(MafiaPlayer *)player1 andPlayer:(MafiaPlayer *)player2;

- (IBAction)player1ButtonTapped:(id)sender;

- (IBAction)player2ButtonTapped:(id)sender;

@end  // MafiaTwoPlayersCell


@interface MafiaAssignRolesController : UITableViewController

@property (strong, nonatomic) MafiaGame *game;

@property (strong, nonatomic) UIBarButtonItem *addBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *editBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *doneEditingBarButtonItem;

- (void)assignRolesRandomlyWithGameSetup:(MafiaGameSetup *)gameSetup;

- (IBAction)startButtonTapped:(id)sender;

@end  // MafiaAssignRolesController
