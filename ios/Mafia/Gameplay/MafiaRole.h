//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * Enumeration class of a role.
 */
@interface MafiaRole : NSObject

@property (readonly, copy, nonatomic) NSString *name;
@property (readonly, copy, nonatomic) NSString *displayName;
@property (readonly, assign, nonatomic) NSInteger alignment;

+ (instancetype)unrevealed;

+ (instancetype)civilian;

+ (instancetype)assassin;

+ (instancetype)guardian;

+ (instancetype)killer;

+ (instancetype)detective;

+ (instancetype)doctor;

+ (instancetype)traitor;

+ (instancetype)undercover;

/*!
 * Returns an array of all available roles.
 */
+ (NSArray *)roles;

/*!
 * Designated initializer. This initializer should not be used externally.
 */
- (instancetype)initWithName:(NSString *)name
                 displayName:(NSString *)displayName
                   alignment:(NSInteger)alignment
    NS_DESIGNATED_INITIALIZER;

/*!
 * Checks equality.
 */
- (BOOL)isEqualToRole:(MafiaRole *)otherRole;

@end  // MafiaRole
