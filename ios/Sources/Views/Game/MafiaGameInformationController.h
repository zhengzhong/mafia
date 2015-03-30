//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaInformation;
@class MafiaGameInformationController;


@protocol MafiaGameInformationControllerDelegate <NSObject>

- (void)informationControllerDidComplete:(MafiaGameInformationController *)controller;

@end // MafiaGameInformationControllerDelegate


@interface MafiaGameInformationController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailsLabel;
@property (strong, nonatomic) MafiaInformation *information;
@property (readonly, weak, nonatomic) id<MafiaGameInformationControllerDelegate> delegate;

+ (id)controllerWithDelegate:(id<MafiaGameInformationControllerDelegate>)delegate;

- (id)initWithDelegate:(id<MafiaGameInformationControllerDelegate>)delegate;
- (void)presentInformation:(MafiaInformation *)information inSuperview:(UIView *)superview;
- (void)dismissInformationFromSuperview;

- (IBAction)dismissButtonTapped:(id)sender;

@end // MafiaGameInformationController

