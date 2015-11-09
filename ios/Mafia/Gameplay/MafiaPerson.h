//
//  Created by ZHENG Zhong on 2015-04-14.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>  // for UIImage

#import "Mantle/Mantle.h"

/**
 * This class represents one physical person. If the game is in two-handed mode, one person will
 * control 2 players, one for each hand side; Otherwise, one person controls one player.
 */
@interface MafiaPerson : MTLModel <MTLJSONSerializing>

/// The name of the person.
@property (readonly, copy, nonatomic) NSString *name;

/// The avatar image of the person.
@property (strong, nonatomic) UIImage *avatarImage;

+ (instancetype)personWithName:(NSString *)name avatarImage:(UIImage *)avatarImage;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithName:(NSString *)name avatarImage:(UIImage *)avatarImage
    NS_DESIGNATED_INITIALIZER;

- (BOOL)isEqualToPerson:(MafiaPerson *)otherPerson;

@end
