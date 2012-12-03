//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MafiaGame;
@class MafiaGameSetup;


@interface MafiaGamePlayController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) IBOutlet UIImageView *dayNightImageView;
@property (retain, nonatomic) IBOutlet UILabel *actionLabel;
@property (retain, nonatomic) IBOutlet UITableView *playersTableView;

@property (retain, nonatomic) MafiaGame *game;
@property (retain, nonatomic) NSMutableArray *selectedPlayers;

+ (UIViewController *)controllerWithGameSetup:(MafiaGameSetup *)gameSetup;

- (id)initWithGameSetup:(MafiaGameSetup *)gameSetup;

- (void)reloadData;

- (IBAction)resetGame:(id)sender;

- (IBAction)continueToNext:(id)sender;

- (IBAction)playerAccessoryButtonTapped:(id)sender;

@end // MafiaGamePlayController

