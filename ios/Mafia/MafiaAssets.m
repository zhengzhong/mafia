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
            @(MafiaColorStyleMuted): [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0],
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
    NSString *avatarImageName = avatarImageNames[@(avatar)];
    if (avatarImageName == nil) {
        NSLog(@"Fail to find image name for avatar: %@", @(avatar));
        return nil;
    }
    return [UIImage imageNamed:avatarImageName];
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
    NSString *roleImageName = roleImageNames[role];
    if (roleImageName == nil) {
        NSLog(@"Fail to find image name for role: %@", role);
        return nil;
    }
    return [UIImage imageNamed:roleImageName];
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


+ (UIImage *)defaultUserAvatar {
    return [UIImage imageNamed:@"default_user_avatar_80pt"];
}


@end
