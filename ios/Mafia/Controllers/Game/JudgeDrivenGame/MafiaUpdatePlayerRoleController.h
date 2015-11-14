//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MafiaRole;

@protocol MafiaUpdatePlayerRoleControllerDelegate <NSObject>

- (void)updatePlayerRoleController:(UIViewController *)controller didUpdateRole:(MafiaRole *)role;

@end


@interface MafiaUpdatePlayerRoleController : UITableViewController

@property (strong, nonatomic) MafiaRole *originalRole;
@property (strong, nonatomic) MafiaRole *selectedRole;
@property (copy, nonatomic) NSArray *roles;

@property (weak, nonatomic) id<MafiaUpdatePlayerRoleControllerDelegate> delegate;

- (void)setRole:(MafiaRole *)role;

- (IBAction)cancelButtonTapped:(id)sender;

- (IBAction)doneButtonTapped:(id)sender;

@end
