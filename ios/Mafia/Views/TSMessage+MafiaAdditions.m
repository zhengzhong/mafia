//
//  Created by ZHENG Zhong on 2015-04-13.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "TSMessage+MafiaAdditions.h"

#import "MafiaAssets.h"
#import "MafiaGameplay.h"


static const NSTimeInterval kMessageDuration = 30;  // be long enough!


@implementation TSMessage (MafiaAdditions)


+ (void)mafia_showMessageAndDetailsOfInformation:(MafiaInformation *)information {
    NSAssert(information != nil, @"Information to show should not be nil.");
    NSString *subtitle = nil;
    if ([information.details count] > 0) {
        subtitle = [information.details componentsJoinedByString:@"\n"];
    }
    [self mafia_showMessageOfInformation:information subtitle:subtitle];
}


+ (void)mafia_showMessageOfInformation:(MafiaInformation *)information
                              subtitle:(NSString *)subtitle {
    NSAssert(information != nil, @"Information to show should not be nil.");
    NSString *title = information.message;
    UIImage *image = nil;
    TSMessageNotificationType type = TSMessageNotificationTypeMessage;
    switch (information.type) {
        case MafiaInformationTypeAnnouncement:
            image = [MafiaAssets imageOfAnnouncement];
            type = TSMessageNotificationTypeMessage;
            break;
        case MafiaInformationTypePositiveAnswer:
            image = [MafiaAssets imageOfPositiveAnswer];
            type = TSMessageNotificationTypeSuccess;
            break;
        case MafiaInformationTypeNegativeAnswer:
            image = [MafiaAssets imageOfNegativeAnswer];
            type = TSMessageNotificationTypeError;
            break;
    }
    [self mafia_showNotificationWithTitle:title subtitle:subtitle image:image type:type];
}


+ (void)mafia_showGameResultWithWinner:(MafiaWinner)winner {
    NSString *title = nil;
    TSMessageNotificationType type = TSMessageNotificationTypeMessage;
    switch (winner) {
        case MafiaWinnerCivilians:
            title = NSLocalizedString(@"Game over! Civilians Win!", nil);
            type = TSMessageNotificationTypeSuccess;
            break;
        case MafiaWinnerKillers:
            title = NSLocalizedString(@"Game over! Killers Win!", nil);
            type = TSMessageNotificationTypeError;
            break;
        case MafiaWinnerUnknown:
            NSAssert(NO, @"Winner should not be MafiaWinnerUnknown when showing game result.");
            break;
    }
    [self mafia_showNotificationWithTitle:title subtitle:nil image:nil type:type];
}


+ (void)mafia_showMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [self mafia_showNotificationWithTitle:title subtitle:subtitle image:nil type:TSMessageNotificationTypeMessage];
}


+ (void)mafia_showSuccessWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [self mafia_showNotificationWithTitle:title subtitle:subtitle image:nil type:TSMessageNotificationTypeSuccess];
}


+ (void)mafia_showErrorWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [self mafia_showNotificationWithTitle:title subtitle:subtitle image:nil type:TSMessageNotificationTypeError];
}


#pragma mark - Private


+ (void)mafia_showNotificationWithTitle:(NSString *)title
                               subtitle:(NSString *)subtitle
                                  image:(UIImage *)image
                                   type:(TSMessageNotificationType)type {
    [self showNotificationInViewController:[self defaultViewController]
                                     title:title
                                  subtitle:subtitle
                                     image:image
                                      type:type
                                  duration:kMessageDuration
                                  callback:nil
                               buttonTitle:nil
                            buttonCallback:nil
                                atPosition:TSMessageNotificationPositionTop
                      canBeDismissedByUser:YES];
}


@end
