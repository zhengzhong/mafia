//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAddPersonController.h"
#import "UIImage+MafiaAdditions.h"

#import "MafiaGameplay.h"
#import "UIView+MafiaAdditions.h"


static const CGFloat kAvatarImageDisplayWidth = 160;
static const CGFloat kAvatarImageWidth = 48;


@interface MafiaAddPersonController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end


@implementation MafiaAddPersonController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.playerAvatarImageView mafia_makeRoundCornersWithBorder:NO];
    [self.playerNameField mafia_makeUnderline];
}


#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *avatarImage = info[UIImagePickerControllerEditedImage];
    if (avatarImage == nil) {
        avatarImage = info[UIImagePickerControllerOriginalImage];
    }
    self.avatarImage = [avatarImage mafia_imageByCroppingToSquareOfLength:kAvatarImageDisplayWidth];
    self.playerAvatarImageView.image = self.avatarImage;
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Actions


- (IBAction)playerNameFieldDidChange:(id)sender {
    [self mafia_refreshUI];
}


- (IBAction)addPhotoButtonTapped:(id)sender {
    [self.view endEditing:NO];

    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(@"Add a photo for the player", nil)
                         message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];

    // Allow user to take a photo using the device camera, if it's available.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertAction *takePhotoAction = [UIAlertAction
            actionWithTitle:NSLocalizedString(@"Take a Photo", nil)
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                [self mafia_presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
            }];
        [alertController addAction:takePhotoAction];
    }

    // Allow user to pick an image from photo library, it's available.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIAlertAction *pickPhotoAction = [UIAlertAction
            actionWithTitle:NSLocalizedString(@"Pick from Photo Library", nil)
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                [self mafia_presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }];
        [alertController addAction:pickPhotoAction];
    }

    // Allow user to cancel.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:nil];
}


- (IBAction)cancelButtonTapped:(id)sender {
    [self.delegate addPersonController:self didAddPersonOrNil:nil];
}


- (IBAction)doneButtonTapped:(id)sender {
    // Remove compiler warning: Weak property 'delegate' is accessed multiple times in this method
    // but may be unpredictably set to nil; assign to a strong variable to keep the object alive.
    id<MafiaAddPersonControllerDelegate> strongDelegate = self.delegate;
    NSString *name = [self.playerNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (name == nil || [name length] == 0) {
        [strongDelegate addPersonController:self didAddPersonOrNil:nil];
    } else {
        UIImage *avatarImage = [self.avatarImage mafia_imageByCroppingToSquareOfLength:kAvatarImageWidth];
        MafiaPerson *person = [MafiaPerson personWithName:name avatarImage:avatarImage];
        [strongDelegate addPersonController:self didAddPersonOrNil:person];
    }
}


- (IBAction)backgroundTapped:(id)sender {
    [self.playerNameField resignFirstResponder];  // Dismiss keyboard if necessary.
}


#pragma mark - Private Methods


- (void)mafia_presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)mafia_refreshUI {
    NSString *name = [self.playerNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.doneButton.enabled = (name != nil && [name length] > 0);
}

@end
