//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaInformation.h"


@implementation MafiaInformation


+ (instancetype)announcementInformation {
    return [[self alloc] initWithInformationType:MafiaInformationTypeAnnouncement];
}


+ (instancetype)informationWithAnswer:(BOOL)answer {
    MafiaInformationType type = (answer ? MafiaInformationTypePositiveAnswer : MafiaInformationTypeNegativeAnswer);
    NSString *message = (answer ? NSLocalizedString(@"YES!", nil) : NSLocalizedString(@"NO!", nil));
    MafiaInformation *information = [[self alloc] initWithInformationType:type];
    information.message = message;
    return information;
}


- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Unavailable"
                                 userInfo:nil];
}


- (instancetype)initWithInformationType:(MafiaInformationType)type {
    if (self = [super init]) {
        _type = type;
        _details = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}


- (void)addDetails:(NSArray *)details {
    [self.details addObjectsFromArray:details];
}


@end
