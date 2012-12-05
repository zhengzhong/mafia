//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MafiaGamePlayerController.h"
#import "MafiaGameInformationController.h"


@class MafiaGame;
@class MafiaGameSetup;


@interface MafiaGamePlayController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MafiaGamePlayerControllerDelegate, MafiaGameInformationDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *dayNightImageView;
@property (retain, nonatomic) IBOutlet UILabel *actionLabel;
@property (retain, nonatomic) IBOutlet UILabel *promptLabel;
@property (retain, nonatomic) IBOutlet UITableView *playersTableView;
@property (retain, nonatomic) MafiaGameInformationController *informationController;
@property (retain, nonatomic) MafiaGame *game;
@property (retain, nonatomic) NSMutableArray *selectedPlayers;

+ (UIViewController *)controllerWithGameSetup:(MafiaGameSetup *)gameSetup;

- (id)initWithGameSetup:(MafiaGameSetup *)gameSetup;

- (void)reloadData;

- (void)confirmResetGame:(id)sender;

- (void)continueToNextAction:(id)sender;

- (IBAction)playerAccessoryButtonTapped:(id)sender;

@end // MafiaGamePlayController

