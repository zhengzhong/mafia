//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, MafiaInformationKind) {
    MafiaInformationKindAnnouncement,
    MafiaInformationKindPositiveAnswer,
    MafiaInformationKindNegativeAnswer,
};


/*!
 * This class encapsulates information from an action.
 */
@interface MafiaInformation : NSObject

@property (readonly, assign, nonatomic) MafiaInformationKind kind;
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSMutableArray *details;

/*!
 * Creates an announcement information.
 */
+ (instancetype)announcementInformation;

/*!
 * Creates an information containing an answer of yes or no.
 */
+ (instancetype)informationWithAnswer:(BOOL)answer;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithKind:(MafiaInformationKind)kind NS_DESIGNATED_INITIALIZER;

- (void)addDetails:(NSArray *)details;

@end  // MafiaInformation
