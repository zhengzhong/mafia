//
//  Created by ZHENG Zhong on 2015-04-13.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "TSMessage+MafiaAdditions.h"

#import "MafiaGameplay.h"


static NSString *const kAnnouncementImageName = @"information_announcement.png";
static NSString *const kPositiveAnswerImageName = @"information_positive.png";
static NSString *const kNegativeAnswerImageName = @"information_negative.png";
static NSString *const kMessageImageName = @"information_message.png";
static NSString *const kErrorImageName = @"information_error.png";


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
            type = TSMessageNotificationTypeWarning;
            break;
    }
    [self mafia_showNotificationWithTitle:title
                               subtitle:subtitle
                              imageName:imageName
                                   type:type];
}


+ (void)mafia_showMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [self mafia_showNotificationWithTitle:title
                                 subtitle:subtitle
                                imageName:kMessageImageName
                                     type:TSMessageNotificationTypeMessage];
}


+ (void)mafia_showErrorWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [self mafia_showNotificationWithTitle:title
                                 subtitle:subtitle
                                imageName:kErrorImageName
                                     type:TSMessageNotificationTypeError];
}


+ (void)mafia_showNotificationWithTitle:(NSString *)title
                               subtitle:(NSString *)subtitle
                              imageName:(NSString *)imageName
                                   type:(TSMessageNotificationType)type {
    UIImage *image = [UIImage imageNamed:imageName];
    [self showNotificationInViewController:[self defaultViewController]
                                     title:title
                                  subtitle:subtitle
                                     image:image
                                      type:type
                                  duration:TSMessageNotificationDurationEndless
                                  callback:nil
                               buttonTitle:nil
                            buttonCallback:nil
                                atPosition:TSMessageNotificationPositionTop
                      canBeDismissedByUser:YES];
}


@end
