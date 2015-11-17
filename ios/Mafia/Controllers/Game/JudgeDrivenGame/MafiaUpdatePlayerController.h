//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaPlayer;
@class MafiaRole;


@interface MafiaUpdatePlayerRoleCell : UITableViewCell

@property (strong, nonatomic) MafiaRole *role;

- (void)setupWithRole:(MafiaRole *)role;

@end


@interface MafiaUpdatePlayerStatusCell : UITableViewCell

@property (strong, nonatomic) MafiaPlayer *player;
@property (copy, nonatomic) NSString *statusKey;
@property (assign, nonatomic) BOOL statusValue;

@property (strong, nonatomic) IBOutlet UISwitch *valueSwitch;

- (void)setupWithPlayer:(MafiaPlayer *)player statusKey:(NSString *)statusKey;

- (IBAction)switchToggled:(id)sender;

@end


// ------------------------------------------------------------------------------------------------


@class MafiaUpdatePlayerController;

@protocol MafiaUpdatePlayerControllerDelegate <NSObject>

- (void)updatePlayerController:(MafiaUpdatePlayerController *)controller didUpdatePlayer:(MafiaPlayer *)player;

@end


@interface MafiaUpdatePlayerController : UITableViewController

@property (strong, nonatomic) MafiaPlayer *player;
@property (strong, nonatomic) MafiaRole *updatedRole;
@property (weak, nonatomic) id<MafiaUpdatePlayerControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet MafiaUpdatePlayerRoleCell *roleCell;
@property (strong, nonatomic) IBOutlet MafiaUpdatePlayerStatusCell *justGuardedStatusCell;
@property (strong, nonatomic) IBOutlet MafiaUpdatePlayerStatusCell *unguardableStatusCell;
@property (strong, nonatomic) IBOutlet MafiaUpdatePlayerStatusCell *misdiagnosedStatusCell;
@property (strong, nonatomic) IBOutlet MafiaUpdatePlayerStatusCell *votedStatusCell;
@property (strong, nonatomic) IBOutlet MafiaUpdatePlayerStatusCell *deadStatusCell;

- (void)setupWithPlayer:(MafiaPlayer *)player;

- (IBAction)cancelButtonTapped:(id)sender;

- (IBAction)doneButtonTapped:(id)sender;

@end
