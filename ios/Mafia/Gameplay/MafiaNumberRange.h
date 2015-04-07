//
//  Created by ZHENG Zhong on 2012-12-04.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MafiaNumberRange : NSObject

@property (readonly, assign, nonatomic) NSInteger minValue;
@property (readonly, assign, nonatomic) NSInteger maxValue;

+ (instancetype)numberRangeWithSingleValue:(NSInteger)value;

+ (instancetype)numberRangeWithMinValue:(NSInteger)minValue maxValue:(NSInteger)maxValue;

- (instancetype)initWithMinValue:(NSInteger)minValue maxValue:(NSInteger)maxValue
    NS_DESIGNATED_INITIALIZER;

- (BOOL)isNumberInRange:(NSInteger)number;

- (NSString *)formattedStringWithSingleForm:(NSString *)singleForm
                                 pluralForm:(NSString *)pluralForm;

@end  // MafiaNumberRange
