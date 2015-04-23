//
//  Created by ZHENG Zhong on 2015-04-22.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaAlertView;

/// Block of the alert view.
typedef void (^MafiaAlertViewBlock)(MafiaAlertView *alertView);


/*!
 * This class implements a block-based alert view.
 */
@interface MafiaAlertView : NSObject

/// The plain text field, available only when style is UIAlertViewStylePlainTextInput.
@property (readonly, strong, nonatomic) UITextField *plainTextField;

/// The secure text field, available only when style is UIAlertViewStyleSecureTextInput.
@property (readonly, strong, nonatomic) UITextField *secureTextField;

/// The login text field, available only when style is UIAlertViewStyleLoginAndPasswordInput.
@property (readonly, strong, nonatomic) UITextField *loginTextField;

/// The password text field, available only when style is UIAlertViewStyleLoginAndPasswordInput.
@property (readonly, strong, nonatomic) UITextField *passwordTextField;

+ (instancetype)alertWithTitle:(NSString *)title;

+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message;

+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message
                         style:(UIAlertViewStyle)style;

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                        style:(UIAlertViewStyle)style
    NS_DESIGNATED_INITIALIZER;

- (void)setCancelButtonWithTitle:(NSString *)title block:(MafiaAlertViewBlock)block;

- (void)setConfirmButtonWithTitle:(NSString *)title block:(MafiaAlertViewBlock)block;

- (void)show;

@end
