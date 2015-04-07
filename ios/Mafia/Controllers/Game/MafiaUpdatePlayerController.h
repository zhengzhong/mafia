//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaPlayer;
@class MafiaRole;


@interface MafiaPlayerStatus : NSObject

@property (readonly, copy, nonatomic) NSString *name;
@property (readonly, copy, nonatomic) NSString *imageName;
@property (readonly, copy, nonatomic) NSString *key;
@property (assign, nonatomic) BOOL value;

+ (instancetype)statusWithName:(NSString *)name
                     imageName:(NSString *)imageName
                           key:(NSString *)key
                         value:(BOOL)value;

- (instancetype)initWithName:(NSString *)name
                   imageName:(NSString *)imageName
                         key:(NSString *)key
                       value:(BOOL)value;

@end  // MafiaPlayerStatus


@interface MafiaPlayerStatusCell : UITableViewCell

@property (strong, nonatomic) MafiaPlayerStatus *status;

@property (strong, nonatomic) IBOutlet UISwitch *valueSwitch;

- (IBAction)switchToggled:(id)sender;

- (void)refresh;

@end  // MafiaPlayerStatusCell


@interface MafiaUpdatePlayerController : UITableViewController

@property (strong, nonatomic) MafiaPlayer *player;

@property (strong, nonatomic) MafiaRole *role;
@property (strong, nonatomic) MafiaPlayerStatus *deadStatus;
@property (strong, nonatomic) MafiaPlayerStatus *misdiagnosedStatus;
@property (strong, nonatomic) MafiaPlayerStatus *justGuardedStatus;
@property (strong, nonatomic) MafiaPlayerStatus *unguardableStatus;
@property (strong, nonatomic) MafiaPlayerStatus *votedStatus;

@property (strong, nonatomic) IBOutlet UITableViewCell *roleCell;
@property (strong, nonatomic) IBOutlet MafiaPlayerStatusCell *deadStatusCell;
@property (strong, nonatomic) IBOutlet MafiaPlayerStatusCell *misdiagnosedStatusCell;
@property (strong, nonatomic) IBOutlet MafiaPlayerStatusCell *justGuardedStatusCell;
@property (strong, nonatomic) IBOutlet MafiaPlayerStatusCell *unguardableStatusCell;
@property (strong, nonatomic) IBOutlet MafiaPlayerStatusCell *votedStatusCell;

- (void)loadPlayer:(MafiaPlayer *)player;

- (IBAction)cancelButtonTapped:(id)sender;

- (IBAction)doneButtonTapped:(id)sender;

@end  // MafiaUpdatePlayerController
