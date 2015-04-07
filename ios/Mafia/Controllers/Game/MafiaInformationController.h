//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaInformation;


@protocol MafiaInformationControllerDelegate <NSObject>

- (void)informationControllerDidComplete:(UIViewController *)controller;

@end


@interface MafiaInformationController : UIViewController

@property (strong, nonatomic) MafiaInformation *information;
@property (weak, nonatomic) id<MafiaInformationControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailsLabel;

- (IBAction)dismissButtonTapped:(id)sender;

@end
