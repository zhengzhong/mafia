//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MafiaAddPlayerControllerDelegate <NSObject>

- (void)addPlayerController:(UIViewController *)controller
       didAddPlayerWithName:(NSString *)name
                avatarImage:(UIImage *)avatarImage;

@end


@interface MafiaAddPlayerController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) UIImage *avatarImage;
@property (weak, nonatomic) id<MafiaAddPlayerControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *playerAvatarImageView;
@property (strong, nonatomic) IBOutlet UITextField *playerNameField;

- (IBAction)addPhotoButtonTapped:(id)sender;

- (IBAction)cancelButtonTapped:(id)sender;

- (IBAction)doneButtonTapped:(id)sender;

- (IBAction)backgroundTapped:(id)sender;

@end
