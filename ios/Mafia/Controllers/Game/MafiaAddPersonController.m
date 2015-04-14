//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAddPersonController.h"
#import "UIImage+MafiaAdditions.h"

#import "MafiaGameplay.h"


static const CGFloat kAvatarImageWidth = 160;


@interface MafiaAddPersonController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (assign, nonatomic) NSInteger pickFromPhotoLibraryIndex;
@property (assign, nonatomic) NSInteger takePhotoUsingCameraIndex;

@end


@implementation MafiaAddPersonController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // TODO: adjust scroll view position here, otherwise the initial position would be wrong. Don't know why...
    UIScrollView *scrollView = (UIScrollView *)self.view;
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}


#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != self.pickFromPhotoLibraryIndex && buttonIndex != self.takePhotoUsingCameraIndex) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    if (buttonIndex == self.pickFromPhotoLibraryIndex) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *avatarImage = info[UIImagePickerControllerEditedImage];
    if (avatarImage == nil) {
        avatarImage = info[UIImagePickerControllerOriginalImage];
    }
    self.avatarImage = [avatarImage mafia_imageByCroppingToSquareOfLength:kAvatarImageWidth];
    self.playerAvatarImageView.image = self.avatarImage;
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITextFieldDelegate


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // Scroll the view up so that the text field will not be hidden by the keyboard.
    UIScrollView *scrollView = (UIScrollView *)self.view;
    [scrollView setContentOffset:CGPointMake(0, 120) animated:YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    // Scroll the view back.
    UIScrollView *scrollView = (UIScrollView *)self.view;
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}


#pragma mark - Actions


- (IBAction)addPhotoButtonTapped:(id)sender {
    [self.playerNameField resignFirstResponder];  // Make sure keybord is dismissed.
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                 initWithTitle:nil
                      delegate:self
             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
        destructiveButtonTitle:nil
             otherButtonTitles:nil];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.takePhotoUsingCameraIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Take Photo", nil)];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.pickFromPhotoLibraryIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Pick from Photo Library", nil)];
    }
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
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
        MafiaPerson *person = [MafiaPerson personWithName:name avatarImage:self.avatarImage];
        [strongDelegate addPersonController:self didAddPersonOrNil:person];
    }
}


- (IBAction)backgroundTapped:(id)sender {
    [self.playerNameField resignFirstResponder];  // Dismiss keyboard if necessary.
}


@end
