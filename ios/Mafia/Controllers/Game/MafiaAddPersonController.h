//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaPerson;


@protocol MafiaAddPersonControllerDelegate <NSObject>

- (void)addPersonController:(UIViewController *)controller didAddPersonOrNil:(MafiaPerson *)person;

@end


@interface MafiaAddPersonController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) UIImage *avatarImage;
@property (weak, nonatomic) id<MafiaAddPersonControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *playerAvatarImageView;
@property (strong, nonatomic) IBOutlet UITextField *playerNameField;

- (IBAction)addPhotoButtonTapped:(id)sender;

- (IBAction)cancelButtonTapped:(id)sender;

- (IBAction)doneButtonTapped:(id)sender;

- (IBAction)backgroundTapped:(id)sender;

@end
