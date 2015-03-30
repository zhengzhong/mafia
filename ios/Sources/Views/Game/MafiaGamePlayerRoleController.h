//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MafiaRole;
@class MafiaGamePlayerRoleController;


@protocol MafiaGamePlayerRoleControllerDelegate <NSObject>

- (void)playerRoleController:(MafiaGamePlayerRoleController *)controller didCompleteWithRole:(MafiaRole *)role;

@end // MafiaGamePlayerRoleControllerDelegate


@interface MafiaGamePlayerRoleController : UITableViewController

@property (readonly, strong, nonatomic) MafiaRole *originalRole;
@property (strong, nonatomic) MafiaRole *selectedRole;
@property (readonly, copy, nonatomic) NSArray *roles;
@property (readonly, weak, nonatomic) id<MafiaGamePlayerRoleControllerDelegate> delegate;

+ (id)controllerWithRole:(MafiaRole *)role delegate:(id<MafiaGamePlayerRoleControllerDelegate>)delegate;

- (id)initWithRole:(MafiaRole *)role delegate:(id<MafiaGamePlayerRoleControllerDelegate>)delegate;

- (void)doneTapped:(id)sender;

- (void)cancelTapped:(id)sender;

@end // MafiaGamePlayerRoleController

