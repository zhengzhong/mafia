//
//  Created by ZHENG Zhong on 2015-04-20.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT NSString *const MafiaErrorDomain;


/// Project-specific error codes.
typedef NS_ENUM(NSInteger, MafiaErrorCode) {
    MafiaErrorCodeDataPersistence = 0,
};


@interface NSError (MafiaAdditions)

+ (NSError *)mafia_errorOfDataPersistenceWithDescription:(NSString *)description;

@end
