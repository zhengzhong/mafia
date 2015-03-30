//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaInformation.h"


@implementation MafiaInformation


@synthesize category = _category;
@synthesize message = _message;
@synthesize details = _details;


+ (id)announcementInformation
{
    return [[self alloc] initWithCategory:@"announcement"];
}


+ (id)thumbInformationWithIndicator:(BOOL)indicator
{
    NSString *category = (indicator ? @"positive" : @"negative");
    MafiaInformation *information = [[self alloc] initWithCategory:category];
    information.message = (indicator ? NSLocalizedString(@"Thumb Up! Positive!", nil) : NSLocalizedString(@"Thumb Down! Negative!", nil));
    return information;
}




- (id)initWithCategory:(NSString *)category
{
    if (self = [super init])
    {
        _category = [category copy];
        _message = nil;
        _details = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}


- (void)addDetails:(NSArray *)details
{
    [self.details addObjectsFromArray:details];
}


@end // MafiaMessage

