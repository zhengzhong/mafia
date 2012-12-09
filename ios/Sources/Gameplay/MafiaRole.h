//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MafiaRole : NSObject

@property (readonly, copy, nonatomic) NSString *name;
@property (readonly, copy, nonatomic) NSString *displayName;
@property (readonly, assign, nonatomic) NSInteger alignment;

- (id)initWithName:(NSString *)name displayName:(NSString *)displayName alignment:(NSInteger)alignment;

+ (MafiaRole *)unrevealed;

+ (MafiaRole *)civilian;

+ (MafiaRole *)assassin;

+ (MafiaRole *)guardian;

+ (MafiaRole *)killer;

+ (MafiaRole *)detective;

+ (MafiaRole *)doctor;

+ (MafiaRole *)traitor;

+ (MafiaRole *)undercover;

+ (NSArray *)roles;

@end // MafiaRole

