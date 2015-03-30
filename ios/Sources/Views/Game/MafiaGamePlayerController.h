//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MafiaGamePlayerRoleController.h"

@class MafiaPlayer;
@class MafiaRole;
@class MafiaGamePlayerController;


@protocol MafiaGamePlayerControllerDelegate <NSObject>

- (void)playerController:(MafiaGamePlayerController *)controller didCompleteWithPlayer:(MafiaPlayer *)player;

@end // MafiaGamePlayerControllerDelegate


@interface MafiaGamePlayerStatus : NSObject

@property (readonly, copy, nonatomic) NSString *name;
@property (readonly, copy, nonatomic) NSString *imageName;
@property (readonly, copy, nonatomic) NSString *key;
@property (assign, nonatomic) BOOL value;

+ (id)statusWithName:(NSString *)name imageName:(NSString *)imageName key:(NSString *)key value:(BOOL)value;

- (id)initWithName:(NSString *)name imageName:(NSString *)imageName key:(NSString *)key value:(BOOL)value;

@end // MafiaGamePlayerStatus


@interface MafiaGamePlayerController : UITableViewController <MafiaGamePlayerRoleControllerDelegate>

@property (readonly, strong, nonatomic) MafiaPlayer *player;
@property (strong, nonatomic) MafiaRole *role;
@property (readonly, copy, nonatomic) NSArray *statuses;
@property (readonly, weak, nonatomic) id<MafiaGamePlayerControllerDelegate> delegate;

+ (id)controllerWithPlayer:(MafiaPlayer *)player delegate:(id<MafiaGamePlayerControllerDelegate>)delegate;

- (id)initWithPlayer:(MafiaPlayer *)player delegate:(id<MafiaGamePlayerControllerDelegate>)delegate;

- (void)doneTapped:(id)sender;

- (void)cancelTapped:(id)sender;

@end // MafiaGamePlayerController

