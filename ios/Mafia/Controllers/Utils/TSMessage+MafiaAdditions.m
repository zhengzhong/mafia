//
//  Created by ZHENG Zhong on 2015-04-13.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "TSMessage+MafiaAdditions.h"

#import "MafiaGameplay.h"


static NSString *const kAnnouncementImageName = @"InformationAnnouncement";
static NSString *const kPositiveAnswerImageName = @"InformationPositive";
static NSString *const kNegativeAnswerImageName = @"InformationNegative";


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
    NSString *imageName = nil;
    TSMessageNotificationType type = TSMessageNotificationTypeMessage;
    switch (information.kind) {
        case MafiaInformationKindAnnouncement:
            imageName = kAnnouncementImageName;
            type = TSMessageNotificationTypeMessage;
            break;
        case MafiaInformationKindPositiveAnswer:
            imageName = kPositiveAnswerImageName;
            type = TSMessageNotificationTypeSuccess;
            break;
        case MafiaInformationKindNegativeAnswer:
            imageName = kNegativeAnswerImageName;
            type = TSMessageNotificationTypeError;
            break;
    }
    [self mafia_showNotificationWithTitle:title
                               subtitle:subtitle
                              imageName:imageName
                                   type:type];
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
    [self mafia_showNotificationWithTitle:title
                                 subtitle:nil
                                imageName:nil
                                     type:type];
}


+ (void)mafia_showMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [self mafia_showNotificationWithTitle:title
                                 subtitle:subtitle
                                imageName:nil
                                     type:TSMessageNotificationTypeMessage];
}


+ (void)mafia_showErrorWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [self mafia_showNotificationWithTitle:title
                                 subtitle:subtitle
                                imageName:nil
                                     type:TSMessageNotificationTypeError];
}


+ (void)mafia_showNotificationWithTitle:(NSString *)title
                               subtitle:(NSString *)subtitle
                              imageName:(NSString *)imageName
                                   type:(TSMessageNotificationType)type {
    UIImage *image = (imageName != nil ? [UIImage imageNamed:imageName] : nil);
    [self showNotificationInViewController:[self defaultViewController]
                                     title:title
                                  subtitle:subtitle
                                     image:image
                                      type:type
                                  duration:TSMessageNotificationDurationAutomatic
                                  callback:nil
                               buttonTitle:nil
                            buttonCallback:nil
                                atPosition:TSMessageNotificationPositionTop
                      canBeDismissedByUser:YES];
}


@end
