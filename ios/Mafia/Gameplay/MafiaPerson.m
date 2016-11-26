//
//  Created by ZHENG Zhong on 2015-04-14.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaPerson.h"
#import "NSError+MafiaAdditions.h"


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


#pragma mark - MTLJSONSerializing


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"name": @"name",
        @"avatarImage": @"avatar_image",
    };
}


+ (NSValueTransformer *)avatarImageJSONTransformer {
    return [MTLValueTransformer
        transformerUsingForwardBlock:^(NSString *string, BOOL *success, NSError **error) {
            // Transform from a (base64-encoded) string to an image.
            UIImage *image = nil;
            if (string != nil && string.length > 0) {
                NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
                image = [UIImage imageWithData:data];
                if (image == nil) {
                    NSLog(@"Fail to convert base64-encoded string to image.");
                }
            }
            return image;
        }
        reverseBlock:^(UIImage *image, BOOL *success, NSError **error) {
            // Transform from an image to a (base64-encoded) string.
            NSString *string = nil;
            if (image != nil) {
                NSData *data = UIImagePNGRepresentation(image);
                string = [data base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
                if (string == nil) {
                    NSLog(@"Fail to convert image to base64-encoded string.");
                }
            }
            return string;
        }];
}


@end
