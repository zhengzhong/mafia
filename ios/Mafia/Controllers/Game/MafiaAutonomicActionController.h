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


// ------------------------------------------------------------------------------------------------
// Custom Cells
// ------------------------------------------------------------------------------------------------


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

- (void)setupWithTargetPlayer:(MafiaPlayer *)player
                       ofRole:(MafiaRole *)role
                   selectable:(BOOL)selectable
                     selected:(BOOL)selected;

@end  // MafiaTargetPlayerCell


// ------------------------------------------------------------------------------------------------
// MafiaAutonomicActionController
// ------------------------------------------------------------------------------------------------


@protocol MafiaAuthnomicActionControllerDelegate <NSObject>

- (void)autonomicActionControllerDidCompleteAction:(UIViewController *)controller;

@end


@interface MafiaAutonomicActionController : UITableViewController

@property (strong, nonatomic) MafiaGame *game;
@property (strong, nonatomic) NSMutableArray *selectedPlayers;
@property (assign, nonatomic) BOOL isActionCompleted;

@property (weak, nonatomic) id<MafiaAuthnomicActionControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *okBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;

- (void)setupWithGame:(MafiaGame *)game;

- (IBAction)okButtonTapped:(id)sender;

- (IBAction)doneButtonTapped:(id)sender;

@end  // MafiaAutonomicActionController
