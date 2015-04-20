//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAddPersonController.h"
#import "MafiaActionSheet.h"
#import "UIImage+MafiaAdditions.h"

#import "MafiaGameplay.h"


static const CGFloat kAvatarImageDisplayWidth = 160;
static const CGFloat kAvatarImageWidth = 48;

@interface MafiaAddPersonController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end


@implementation MafiaAddPersonController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.playerAvatarImageView.layer.cornerRadius = 20;
    self.playerAvatarImageView.clipsToBounds = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // TODO: adjust scroll view position here, otherwise the initial position would be wrong. Don't know why...
    UIScrollView *scrollView = (UIScrollView *)self.view;
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    [self mafia_refreshUI];
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


- (IBAction)playerNameFieldDidChange:(id)sender {
    [self mafia_refreshUI];
}


- (IBAction)addPhotoButtonTapped:(id)sender {
    // Make sure keybord is dismissed.
    [self.playerNameField resignFirstResponder];
    // Prepare an action sheet.
    MafiaActionSheet *sheet = [MafiaActionSheet sheetWithTitle:nil];
    [sheet setCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil) block:nil];
    // Allow user to take a photo using the device camera, if it's available.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Take a Photo", nil)
                            block:^{
            [self mafia_presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }];
    }
    // Allow user to pick an image from photo library, it's available.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Pick from Photo Library", nil)
                            block:^{
            [self mafia_presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }];
    }
    // Show the action sheet.
    [sheet showInAppKeyWindow];
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
