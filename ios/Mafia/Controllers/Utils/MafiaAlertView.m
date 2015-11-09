//
//  Created by ZHENG Zhong on 2015-04-22.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaAlertView.h"


@interface MafiaAlertView () <UIAlertViewDelegate>

@property (strong, nonatomic) UIAlertView *alertView;
@property (assign, nonatomic) NSInteger confirmButtonIndex;
@property (strong, nonatomic) MafiaAlertViewBlock cancelBlock;
@property (strong, nonatomic) MafiaAlertViewBlock confirmBlock;
@property (strong, nonatomic) MafiaAlertView *selfRetain;

@end


@implementation MafiaAlertView


#pragma mark - Factory Methods and Lifecycle


+ (instancetype)alertWithTitle:(NSString *)title {
    return [[self alloc] initWithTitle:title message:nil style:UIAlertViewStyleDefault];
}


+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message {
    return [[self alloc] initWithTitle:title message:message style:UIAlertViewStyleDefault];
}


+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message
                         style:(UIAlertViewStyle)style {
    return [[self alloc] initWithTitle:title message:message style:style];
}


- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Unavailable"
                                 userInfo:nil];
}


- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                        style:(UIAlertViewStyle)style {
    if (self = [super init]) {
        _alertView = [[UIAlertView alloc] initWithTitle:title
                                                message:message
                                               delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:nil];
        _alertView.alertViewStyle = style;
        _confirmButtonIndex = -1;
        // Retain self so that the instance will not be deallocated.
        _selfRetain = self;
    }
    return self;
}


- (void) dealloc {
    self.alertView.delegate = nil;
}


#pragma mark - Properties


@dynamic plainTextField;

- (UITextField *)plainTextField {
    NSAssert(self.alertView.alertViewStyle == UIAlertViewStylePlainTextInput,
             @"Alert view does not have plain text field.");
    return [self.alertView textFieldAtIndex:0];
}


@dynamic secureTextField;

- (UITextField *)secureTextField {
    NSAssert(self.alertView.alertViewStyle == UIAlertViewStyleSecureTextInput,
             @"Alert view does not have secure text field.");
    return [self.alertView textFieldAtIndex:0];
}


@dynamic loginTextField;

- (UITextField *)loginTextField {
    NSAssert(self.alertView.alertViewStyle == UIAlertViewStyleLoginAndPasswordInput,
             @"Alert view does not have login text field.");
    return [self.alertView textFieldAtIndex:0];
}


@dynamic passwordTextField;

- (UITextField *)passwordTextField {
    NSAssert(self.alertView.alertViewStyle == UIAlertViewStyleLoginAndPasswordInput,
             @"Alert view does not have password text field.");
    return [self.alertView textFieldAtIndex:1];
}


#pragma mark - Public Methods


- (void)setCancelButtonWithTitle:(NSString *)title block:(MafiaAlertViewBlock)block {
    NSAssert(self.alertView.cancelButtonIndex < 0, @"Alert view already has a cancel button.");
    self.alertView.cancelButtonIndex = [self.alertView addButtonWithTitle:title];
    self.cancelBlock = block;
}


- (void)setConfirmButtonWithTitle:(NSString *)title block:(MafiaAlertViewBlock)block {
    NSAssert(self.confirmButtonIndex < 0, @"Alert view already has a confirm button.");
    self.confirmButtonIndex = [self.alertView addButtonWithTitle:title];
    self.confirmBlock = block;
}


- (void)show {
    [self.alertView show];
}


#pragma mark - UIAlertViewDelegate


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // Call the block after the alert view is dismissed and the animation ends.
    MafiaAlertViewBlock block = nil;
    if (buttonIndex == self.alertView.cancelButtonIndex) {
        block = self.cancelBlock;
    } else if (buttonIndex == self.confirmButtonIndex) {
        block = self.confirmBlock;
    }
    if (block != nil) {
        block(self);
    }
    // Release all blocks, to break any potential cyclic reference.
    self.cancelBlock = nil;
    self.confirmBlock = nil;
    // Release self to break the cyclic reference, so that this instance may be deallocated.
    self.selfRetain = nil;
}


@end
