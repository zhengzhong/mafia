//
//  Created by ZHENG Zhong on 2015-04-20.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "NSError+MafiaAdditions.h"


NSString *const MafiaErrorDomain = @"MafiaErrorDomain";


@implementation NSError (MafiaAdditions)

+ (NSError *)mafia_errorOfDataPersistenceWithDescription:(NSString *)description {
    if (description == nil) {
        description = @"No details provided";
    }
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description };
    return [self errorWithDomain:MafiaErrorDomain code:MafiaErrorCodeDataPersistence userInfo:userInfo];
}

@end
