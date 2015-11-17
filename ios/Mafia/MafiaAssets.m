//
//  Created by ZHENG Zhong on 2015-09-07.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaAssets.h"
#import "MafiaRole.h"


@implementation MafiaAssets


+ (UIColor *)colorOfStyle:(MafiaColorStyle)colorStyle {
    static NSDictionary *styledColors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        styledColors = @{
            @(MafiaColorStylePrimary): [UIColor colorWithRed:0.875f green:0.359f blue:0.320f alpha:1.0],  // #E05C52
            @(MafiaColorStyleInfo): [UIColor colorWithRed:0.258f green:0.543f blue:0.789f alpha:1.0],     // #428BCA
            @(MafiaColorStyleSuccess): [UIColor colorWithRed:0.359f green:0.719f blue:0.359f alpha:1.0],  // #5CB85C
            @(MafiaColorStyleWarning): [UIColor colorWithRed:0.938f green:0.676f blue:0.305f alpha:1.0],  // #F0AD4E
            @(MafiaColorStyleDanger): [UIColor colorWithRed:0.848f green:0.324f blue:0.309f alpha:1.0],   // #D9534F
            @(MafiaColorStyleMuted): [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0],
        };
    });

    UIColor *color = styledColors[@(colorStyle)];
    if (color == nil) {
        NSLog(@"Fail to find color for style: %@", @(colorStyle));
        return nil;
    }
    return color;
}


+ (UIImage *)imageOfAvatar:(MafiaAvatar)avatar {
    static NSDictionary *avatarImageNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        avatarImageNames = @{
            @(MafiaAvatarDefault): @"avatar_default_64pt",
            @(MafiaAvatarWenwen): @"avatar_wenwen_64pt",
            @(MafiaAvatarXiaohe): @"avatar_xiaohe_64pt",
            @(MafiaAvatarLangni): @"avatar_langni_64pt",
            @(MafiaAvatarDashu): @"avatar_dashu_64pt",
            @(MafiaAvatarQingqing): @"avatar_qingqing_64pt",
            @(MafiaAvatarLaoyao): @"avatar_laoyao_64pt",
            @(MafiaAvatarInfo): @"avatar_info_64pt",
        };
    });

    NSString *imageName = avatarImageNames[@(avatar)];
    if (imageName == nil) {
        NSLog(@"Fail to find image name for avatar: %@", @(avatar));
        return nil;
    }
    return [UIImage imageNamed:imageName];
}


+ (UIImage *)imageOfRole:(MafiaRole *)role {
    static NSDictionary *roleImageNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        roleImageNames = @{
            [MafiaRole civilian]: @"role_civilian_64pt",
            [MafiaRole assassin]: @"role_assassin_64pt",
            [MafiaRole guardian]: @"role_guardian_64pt",
            [MafiaRole killer]: @"role_killer_64pt",
            [MafiaRole detective]: @"role_policeman_64pt",
            [MafiaRole doctor]: @"role_doctor_64pt",
            [MafiaRole traitor]: @"role_traitor_64pt",
            [MafiaRole undercover]: @"role_undercover_64pt",
        };
    });

    NSString *imageName = roleImageNames[role];
    if (imageName == nil) {
        NSLog(@"Fail to find image name for role: %@", role);
        return nil;
    }
    return [UIImage imageNamed:imageName];
}


+ (UIImage *)smallImageOfRole:(MafiaRole *)role {
    static NSDictionary *roleImageNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        roleImageNames = @{
            [MafiaRole civilian]: @"role_civilian_32pt",
            [MafiaRole assassin]: @"role_assassin_32pt",
            [MafiaRole guardian]: @"role_guardian_32pt",
            [MafiaRole killer]: @"role_killer_32pt",
            [MafiaRole detective]: @"role_policeman_32pt",
            [MafiaRole doctor]: @"role_doctor_32pt",
            [MafiaRole traitor]: @"role_traitor_32pt",
            [MafiaRole undercover]: @"role_undercover_32pt",
        };
    });
    
    NSString *imageName = roleImageNames[role];
    if (imageName == nil) {
        NSLog(@"Fail to find image name for role: %@", role);
        return nil;
    }
    return [UIImage imageNamed:imageName];
}


+ (UIImage *)imageOfStatus:(MafiaStatus)status {
    static NSDictionary *statusImageNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        statusImageNames = @{
            @(MafiaStatusJustGuarded): @"status_just_guarded_24pt",
            @(MafiaStatusUnguardable): @"status_unguardable_24pt",
            @(MafiaStatusMisdiagnosed): @"status_misdiagnosed_24pt",
            @(MafiaStatusVoted): @"status_voted_24pt",
            @(MafiaStatusDead): @"status_dead_24pt",
        };
    });

    NSString *imageName = statusImageNames[@(status)];
    if (imageName == nil) {
        NSLog(@"Fail to find image name for status: %@", @(status));
        return nil;
    }
    return [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}


+ (UIImage *)imageOfAnnouncement {
    return [UIImage imageNamed:@"information_announcement_24pt"];
}


+ (UIImage *)imageOfPositiveAnswer {
    return [UIImage imageNamed:@"information_positive_answer_24pt"];
}


+ (UIImage *)imageOfNegativeAnswer {
    return [UIImage imageNamed:@"information_negative_answer_24pt"];
}


+ (UIImage *)imageOfSelected {
    return [UIImage imageNamed:@"selected_24pt"];
}


+ (UIImage *)imageOfUnselected {
    return [UIImage imageNamed:@"unselected_24pt"];
}


+ (UIImage *)imageOfUnselectable {
    return [UIImage imageNamed:@"unselectable_24pt"];
}


+ (UIImage *)imageOfTag {
    return [UIImage imageNamed:@"tag_24pt"];
}


+ (UIImage *)imageOfIcon:(MafiaIcon)icon {
    static NSDictionary *iconNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iconNames = @{
            @(MafiaIconDummy): @"Dead",
        };
    });

    NSString *iconName = iconNames[@(icon)];
    if (iconName == nil) {
        NSLog(@"Fail to find image name for icon: %@", @(icon));
        return nil;
    }
    return [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}


+ (void)imageView:(UIImageView *)imageView setIcon:(MafiaIcon)icon colorStyle:(MafiaColorStyle)colorStyle {
    imageView.image = [self imageOfIcon:icon];
    imageView.tintColor = [self colorOfStyle:colorStyle];
}


@end
