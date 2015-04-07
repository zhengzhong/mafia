//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>


/*!
 * This class encapsulates information from an action.
 */
@interface MafiaInformation : NSObject

@property (readonly, copy, nonatomic) NSString *category;
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSMutableArray *details;

+ (instancetype)announcementInformation;

+ (instancetype)thumbInformationWithIndicator:(BOOL)indicator;

- (instancetype)initWithCategory:(NSString *)category
    NS_DESIGNATED_INITIALIZER;

- (void)addDetails:(NSArray *)details;

@end  // MafiaInformation
