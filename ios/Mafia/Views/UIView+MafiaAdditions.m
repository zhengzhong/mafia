//
//  Created by ZHENG Zhong on 2015-09-10.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "UIView+MafiaAdditions.h"

static const CGFloat kDefaultCornerRadius = 6;


@implementation UIView (MafiaAdditions)


- (void)mafia_makeRoundCornersWithBorder:(BOOL)border {
    self.layer.cornerRadius = kDefaultCornerRadius;
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
    if (border) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = [self mafia_borderColor].CGColor;
    }
}


- (void)mafia_makeUnderline {
    CALayer *underlineLayer = [CALayer layer];
    underlineLayer.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
    underlineLayer.backgroundColor = [self mafia_borderColor].CGColor;
    [self.layer addSublayer:underlineLayer];
}


// See: http://stackoverflow.com/a/1127025/808898
- (void)mafia_scrollByOffset:(CGFloat)offset upward:(BOOL)upward {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect viewFrame = self.frame;
    if (upward) {
        viewFrame.origin.y -= offset;
    } else {
        viewFrame.origin.y += offset;
    }
    self.frame = viewFrame;
    [UIView commitAnimations];
}


#pragma mark - Private


- (UIColor *)mafia_borderColor {
    return [UIColor colorWithWhite:0.9f alpha:1.0];
}


@end
