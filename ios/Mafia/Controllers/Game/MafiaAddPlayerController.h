//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MafiaAddPlayerController;


@protocol MafiaAddPlayerControllerDelegate <NSObject>

- (void)addPlayerController:(MafiaAddPlayerController *)controller
       didAddPlayerWithName:(NSString *)name;

@end


@interface MafiaAddPlayerController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) id<MafiaAddPlayerControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *playerPhotoImageView;
@property (strong, nonatomic) IBOutlet UITextField *playerNameField;

- (IBAction)addPhotoButtonTapped:(id)sender;

- (IBAction)cancelButtonTapped:(id)sender;

- (IBAction)doneButtonTapped:(id)sender;

- (IBAction)backgroundTapped:(id)sender;

@end
