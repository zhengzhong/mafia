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
<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MafiaGamePlayerControllerDelegate, MafiaGameInformationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *dayNightImageView;
@property (strong, nonatomic) IBOutlet UILabel *actionLabel;
@property (strong, nonatomic) IBOutlet UILabel *promptLabel;
@property (strong, nonatomic) IBOutlet UITableView *playersTableView;
@property (strong, nonatomic) MafiaGameInformationController *informationController;
@property (strong, nonatomic) MafiaGame *game;
@property (strong, nonatomic) NSMutableArray *selectedPlayers;

+ (UIViewController *)controllerWithGameSetup:(MafiaGameSetup *)gameSetup;

- (id)initWithGameSetup:(MafiaGameSetup *)gameSetup;

- (void)reloadData;

- (void)confirmResetGame:(id)sender;

- (void)continueToNextAction:(id)sender;

- (IBAction)playerAccessoryButtonTapped:(id)sender;

@end // MafiaGamePlayController

