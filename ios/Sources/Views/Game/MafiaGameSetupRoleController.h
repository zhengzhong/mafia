//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MafiaRole;
@class MafiaGameSetupRoleController;


@protocol MafiaGameSetupRoleControllerDelegate <NSObject>

- (void)roleController:(MafiaGameSetupRoleController *)controller didSelectValue:(NSInteger)value forRole:(MafiaRole *)role;

@end // MafiaGameSetupRoleDelegate


@interface MafiaGameSetupRoleController : UITableViewController

@property (readonly, strong, nonatomic) MafiaRole *role;
@property (readonly, assign, nonatomic) NSInteger minValue;
@property (readonly, assign, nonatomic) NSInteger maxValue;
@property (assign, nonatomic) NSInteger value;
@property (readonly, weak, nonatomic) id<MafiaGameSetupRoleControllerDelegate> delegate;

+ (id)controllerWithRole:(MafiaRole *)role
                minValue:(NSInteger)minValue
                maxValue:(NSInteger)maxValue
                   value:(NSInteger)value
                delegate:(id<MafiaGameSetupRoleControllerDelegate>)delegate;

- (id)initWithRole:(MafiaRole *)role
          minValue:(NSInteger)minValue
          maxValue:(NSInteger)maxValue
             value:(NSInteger)value
          delegate:(id<MafiaGameSetupRoleControllerDelegate>)delegate;

- (void)doneTapped:(id)sender;

@end // MafiaGameSetupRoleController

