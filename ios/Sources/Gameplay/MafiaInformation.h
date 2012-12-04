//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MafiaInformation : NSObject

@property (readonly, copy, nonatomic) NSString *category;
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSMutableArray *details;

+ (id)announcementInformation;

+ (id)thumbInformationWithIndicator:(BOOL)indicator;

- (id)initWithCategory:(NSString *)category;

- (void)addDetails:(NSArray *)details;

@end // MafiaInformation

