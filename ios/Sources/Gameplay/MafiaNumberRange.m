//
//  Created by ZHENG Zhong on 2012-12-04.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaNumberRange.h"


@implementation MafiaNumberRange


@synthesize minValue = _minValue;
@synthesize maxValue = _maxValue;


+ (id)numberRangeWithSingleValue:(NSInteger)value
{
    return [[self alloc] initWithSingleValue:value];
}


+ (id)numberRangeWithMinValue:(NSInteger)minValue maxValue:(NSInteger)maxValue
{
    return [[self alloc] initWithMinValue:minValue maxValue:maxValue];
}


- (id)initWithSingleValue:(NSInteger)value
{
    self = [self initWithMinValue:value maxValue:value];
    return self;
}


- (id)initWithMinValue:(NSInteger)minValue maxValue:(NSInteger)maxValue
{
    NSAssert(maxValue >= minValue, @"Invalid minValue/maxValue in number range.");
    if (self = [super init])
    {
        _minValue = minValue;
        _maxValue = maxValue;
    }
    return self;
}


- (BOOL)isNumberInRange:(NSInteger)number
{
    return (number >= self.minValue && number <= self.maxValue);
}


- (NSString *)formattedStringWithSingleForm:(NSString *)singleForm pluralForm:(NSString *)pluralForm
{
    NSString *singleOrPluralForm = (self.maxValue <= 1 ? singleForm : pluralForm);
    if (self.minValue == self.maxValue)
    {
        return [NSString stringWithFormat:@"%@ %@", @(self.minValue), singleOrPluralForm];
    }
    else
    {
        return [NSString stringWithFormat:@"%@ ~ %@ %@", @(self.minValue), @(self.maxValue), singleOrPluralForm];
    }
}


@end // MafiaNumberRange

