//
//  Created by ZHENG Zhong on 2015-04-16.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Block of the action sheet.
typedef void (^V5MafiaActionSheetBlock)();


/*!
 * This class implements a block-based action sheet.
 *
 * See: https://github.com/candyan/YAUIKit/tree/master/Source/YAActionSheet
 */
@interface MafiaActionSheet : NSObject

/*!
 * Returns an action sheet.
 * @param title  The title of the action sheet, may be nil.
 */
+ (instancetype)sheetWithTitle:(NSString *)title;

- (instancetype)init NS_UNAVAILABLE;

/*!
 * Initializes an action sheet.
 * @param title  The title of the action sheet, may be nil.
 */
- (instancetype)initWithTitle:(NSString *)title NS_DESIGNATED_INITIALIZER;

/*!
 * Customizes the cancel button with a title and a callback block. This method should not be called
 * more than once, as an action sheet should have at most 1 cancel button.
 * @param title  The title of the cancel button, must not be nil.
 * @param block  The callback block when the cancel button is tapped, may be nil.
 */
- (void)setCancelButtonWithTitle:(NSString *)title block:(V5MafiaActionSheetBlock)block;

/*!
 * Customizes the destructive button with a title and a callback block. This method should not be
 * called more than once, as an action sheet should have at most 1 destructive button.
 * @param title  The title of the destructive button, must not be nil.
 * @param block  The callback block when the destructive button is tapped, may be nil.
 */
- (void)setDestructiveButtonWithTitle:(NSString *)title block:(V5MafiaActionSheetBlock)block;

/*!
 * Adds a custom button to the action sheet, with a callback block.
 * @param title  The title of the new button, must not be nil.
 * @param block  The callback block when this button is tapped, may be nil.
 * @return The index of the new button.
 */
- (NSInteger)addButtonWithTitle:(NSString *)title block:(V5MafiaActionSheetBlock)block;

/*!
 * Displays an action sheet that originates from the specified tab bar.
 * @param tabBar  The tab bar from which the action sheet originates.
 */
- (void)showFromTabBar:(UITabBar *)tabBar;

/*!
 * Displays an action sheet that originates from the specified toolbar.
 * @param toolbar  The toolbar from which the action sheet originates.
 */
- (void)showFromToolbar:(UIToolbar *)toolbar;

/*!
 * Displays an action sheet that originates from the specified view.
 * @param view  The view from which the action sheet originates.
 */
- (void)showInView:(UIView *)view;

/*!
 * Displays an action sheet that originates from the app's key window. Use this method if the
 * current view controller is embedded in a tab bar controller, so that the action sheet will not
 * be partly hidden by the tab bar.
 *
 * See: http://stackoverflow.com/questions/4447563/
 */
- (void)showInAppKeyWindow;

@end
