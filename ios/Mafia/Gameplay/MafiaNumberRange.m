//
//  Created by ZHENG Zhong on 2012-12-04.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaNumberRange.h"


@implementation MafiaNumberRange


+ (instancetype)numberRangeWithSingleValue:(NSInteger)value {
    return [[self alloc] initWithMinValue:value maxValue:value];
}


+ (instancetype)numberRangeWithMinValue:(NSInteger)minValue maxValue:(NSInteger)maxValue {
    return [[self alloc] initWithMinValue:minValue maxValue:maxValue];
}


- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Unavailable"
                                 userInfo:nil];
}


- (instancetype)initWithMinValue:(NSInteger)minValue maxValue:(NSInteger)maxValue {
    NSAssert(maxValue >= minValue, @"Invalid minValue/maxValue in number range.");
    if (self = [super init]) {
        _minValue = minValue;
        _maxValue = maxValue;
    }
    return self;
}


- (BOOL)isNumberInRange:(NSInteger)number {
    return (number >= self.minValue && number <= self.maxValue);
}


- (NSString *)string {
    if (self.minValue == self.maxValue) {
        return [NSString stringWithFormat:@"%@", @(self.minValue)];
    } else {
        return [NSString stringWithFormat:@"%@ ~ %@", @(self.minValue), @(self.maxValue)];
    }
}


@end
