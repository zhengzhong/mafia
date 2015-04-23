//
//  Created by ZHENG Zhong on 2015-04-16.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaActionSheet.h"


@interface MafiaActionSheet () <UIActionSheetDelegate>

@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (readonly, strong, nonatomic) NSMutableDictionary *blocks;
@property (strong, nonatomic) MafiaActionSheet *selfRetain;

@end


@implementation MafiaActionSheet


#pragma mark - Factory Method and Lifecycle


+ (instancetype)sheetWithTitle:(NSString *)title {
    return [[self alloc] initWithTitle:title];
}


- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:nil];
        _blocks = [[NSMutableDictionary alloc] initWithCapacity:5];
        // Retain self so that the instance will not be deallocated.
        _selfRetain = self;
    }
    return self;
}


- (void) dealloc {
    self.actionSheet.delegate = nil;
}


#pragma mark - Public Methods


- (void)setCancelButtonWithTitle:(NSString *)title block:(V5MafiaActionSheetBlock)block {
    NSAssert(self.actionSheet.cancelButtonIndex < 0, @"Action sheet already has a cancel button.");
    NSInteger buttonIndex = [self addButtonWithTitle:title block:block];
    self.actionSheet.cancelButtonIndex = buttonIndex;
}


- (void)setDestructiveButtonWithTitle:(NSString *)title block:(V5MafiaActionSheetBlock)block {
    NSAssert(self.actionSheet.destructiveButtonIndex < 0, @"Action sheet already has a destructive button.");
    NSInteger buttonIndex = [self addButtonWithTitle:title block:block];
    self.actionSheet.destructiveButtonIndex = buttonIndex;
}


- (NSInteger)addButtonWithTitle:(NSString *)title block:(V5MafiaActionSheetBlock)block {
    NSAssert([title length] > 0, @"Button title cannot be empty.");
    NSInteger buttonIndex = [self.actionSheet addButtonWithTitle:title];
    if (block != nil) {
        self.blocks[@(buttonIndex)] = block;
    }
    return buttonIndex;
}


- (void)showFromTabBar:(UITabBar *)tabBar {
    [self.actionSheet showFromTabBar:tabBar];
}


- (void)showFromToolbar:(UIToolbar *)toolbar {
    [self.actionSheet showFromToolbar:toolbar];
}


- (void)showInView:(UIView *)view {
    [self.actionSheet showInView:view];
}


- (void)showInAppKeyWindow {
    [self.actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}


#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // Call the block after the action sheet is dismissed and the animation ends.
    V5MafiaActionSheetBlock block = self.blocks[@(buttonIndex)];
    if (block != nil) {
        block();
    }
    // Release all blocks: block may hold a strong reference to the instance which holds a strong
    // reference to this sheet, so we release all blocks to break any potential cyclic reference.
    [self.blocks removeAllObjects];
    // Release self to break the cyclic reference, so that this instance may be deallocated.
    self.selfRetain = nil;
}


@end
