//
//  Created by ZHENG Zhong on 2015-04-11.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaGame;
@class MafiaInformation;
@class MafiaNumberRange;
@class MafiaPlayer;
@class MafiaRole;


@protocol MafiaAuthnomicActionControllerDelegate <NSObject>

- (void)autonomicActionControllerDidCompleteAction:(UIViewController *)controller;

@end


@interface MafiaAutonomicActorCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *roleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *roleImageView;
@property (strong, nonatomic) IBOutlet UILabel *promptLabel;

- (void)setupWithPlayer:(MafiaPlayer *)player numberOfChoices:(MafiaNumberRange *)numberOfChoices;

@end  // MafiaAutonomicActorCell


@interface MafiaTargetPlayerCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;

- (void)setupWithTargetPlayer:(MafiaPlayer *)player ofRole:(MafiaRole *)role selected:(BOOL)isSelected;

@end  // MafiaTargetPlayerCell


@interface MafiaAutonomicActionController : UITableViewController

@property (strong, nonatomic) MafiaGame *game;
@property (strong, nonatomic) NSMutableArray *selectedPlayers;
@property (strong, nonatomic) MafiaInformation *information;

@property (weak, nonatomic) id<MafiaAuthnomicActionControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *okBarButtonItem;

- (void)setupWithGame:(MafiaGame *)game;

- (IBAction)okButtonTapped:(id)sender;

@end  // MafiaAutonomicActionController
