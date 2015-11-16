//
//  Created by ZHENG Zhong on 2015-04-14.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "UIImage+MafiaAdditions.h"


@implementation UIImage (MafiaAdditions)


// See: http://stackoverflow.com/questions/23438442/
- (UIImage *)mafia_imageByCroppingToSquareOfLength:(CGFloat)length {
    CGFloat scaleRatio = 0;
    CGPoint origin = CGPointMake(0, 0);
    if (self.size.width > self.size.height) {
        scaleRatio = length / self.size.height;
        origin = CGPointMake(-(self.size.width - self.size.height) / 2.0f, 0);
    } else {
        scaleRatio = length / self.size.width;
        origin = CGPointMake(0, -(self.size.height - self.size.width) / 2.0f);
    }
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
    // Create a graphic context and transforms the coordinate system.
    CGSize squareSize = CGSizeMake(length, length);
    UIGraphicsBeginImageContextWithOptions(squareSize, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    // Draw the image to the graphic context, and get the new image.
    [self drawAtPoint:origin];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return croppedImage;
}


// See: http://stackoverflow.com/questions/1298867/
- (UIImage *)mafia_grayscaledImage {
    // Create a graphic context, with alpha channel and the same scale as this image.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    // Draw a white background.
    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(context, imageRect);
    // Draw with the luminosity blend mode on top of the white background to get grayscale.
    [self drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0f];
    // Apply the alpha channel.
    [self drawInRect:imageRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    // Get the resulting image.
    UIImage *grayscaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return grayscaledImage;
}


@end
