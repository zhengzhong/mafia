//
//  Created by ZHENG Zhong on 2015-04-14.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaPerson.h"


@implementation MafiaPerson


+ (instancetype)personWithName:(NSString *)name avatarImage:(UIImage *)avatarImage {
    return [[self alloc] initWithName:name avatarImage:avatarImage];
}


- (instancetype)initWithName:(NSString *)name avatarImage:(UIImage *)avatarImage {
    if (self = [super init]) {
        _name = [name copy];
        _avatarImage = avatarImage;
    }
    return self;
}


- (BOOL)isEqualToPerson:(MafiaPerson *)otherPerson {
    if (self == otherPerson) {
        return YES;
    }
    return [self.name isEqualToString:otherPerson.name];
}


- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (other == nil || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToPerson:other];
}


- (NSString *)description {
    return self.name;
}


@end
