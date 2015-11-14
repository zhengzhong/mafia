//
//  Created by ZHENG Zhong on 2015-09-10.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MafiaAdditions)

/// Updates the view's layer by adding round corners and optionally a border.
/// This is typically used to render a UIButton, a UIImageView or a UITextView.
- (void)mafia_makeRoundCornersWithBorder:(BOOL)border;

/// Updates the view's layer by adding an underline. This is typicaly used to render a UITextField.
- (void)mafia_makeUnderline;

/// Scrolls the view upward or backward by the given offset, depending on the `upward` argument.
/// This is to prevent some input fields to be hidden by the keyboard.
- (void)mafia_scrollByOffset:(CGFloat)offset upward:(BOOL)upward;

@end
