//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaInformation.h"


@implementation MafiaInformation


+ (instancetype)announcementInformation {
    return [[self alloc] initWithKind:MafiaInformationKindAnnouncement];
}


+ (instancetype)informationWithAnswer:(BOOL)answer {
    MafiaInformationKind kind = (answer ? MafiaInformationKindPositiveAnswer : MafiaInformationKindNegativeAnswer);
    NSString *message = (answer ? NSLocalizedString(@"The answer is YES!", nil) : NSLocalizedString(@"The answer is NO!", nil));
    MafiaInformation *information = [[self alloc] initWithKind:kind];
    information.message = message;
    return information;
}


- (instancetype)initWithKind:(MafiaInformationKind)kind {
    if (self = [super init]) {
        _kind = kind;
        _details = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}


- (void)addDetails:(NSArray *)details {
    [self.details addObjectsFromArray:details];
}


@end  // MafiaMessage
