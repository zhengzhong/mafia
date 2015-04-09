//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaGame;
@class MafiaGameSetup;
@class MafiaInformation;
@class MafiaPlayer;


@interface MafiaGamePlayerCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *roleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *roleImageView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *statusImageViews;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *tagImageViews;

- (void)refreshWithPlayer:(MafiaPlayer *)player;

@end  // MafiaGamePlayerCell


@interface MafiaGameController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *dayNightImageView;
@property (strong, nonatomic) IBOutlet UILabel *actionLabel;
@property (strong, nonatomic) IBOutlet UILabel *promptLabel;
@property (strong, nonatomic) IBOutlet UITableView *playersTableView;

@property (strong, nonatomic) MafiaGame *game;
@property (strong, nonatomic) NSMutableArray *selectedPlayers;
@property (strong, nonatomic) MafiaInformation *information;

- (void)startWithGameSetup:(MafiaGameSetup *)gameSetup;

- (IBAction)nextButtonTapped:(id)sender;

- (IBAction)resetButtonTapped:(id)sender;

@end  // MafiaGameController
