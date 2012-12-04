//
//  Created by ZHENG Zhong on 2012-12-04.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MafiaNumberRange : NSObject

@property (readonly, assign, nonatomic) NSInteger minValue;
@property (readonly, assign, nonatomic) NSInteger maxValue;

+ (id)numberRangeWithSingleValue:(NSInteger)value;

+ (id)numberRangeWithMinValue:(NSInteger)minValue maxValue:(NSInteger)maxValue;

- (id)initWithSingleValue:(NSInteger)value;

- (id)initWithMinValue:(NSInteger)minValue maxValue:(NSInteger)maxValue;

- (BOOL)isNumberInRange:(NSInteger)number;

- (NSString *)formattedStringWithSingleForm:(NSString *)singleForm pluralForm:(NSString *)pluralForm;

- (NSString *)formattedStringWithSingleForm:(NSString *)singleForm;

@end // MafiaNumberRange

