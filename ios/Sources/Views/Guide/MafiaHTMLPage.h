//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MafiaHTMLPage : NSObject

@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, copy, nonatomic) NSString *pageName;
@property (readonly, copy, nonatomic) NSString *language;

+ (id)pageWithTitle:(NSString *)title pageName:(NSString *)pageName language:(NSString *)language;

- (id)initWithTitle:(NSString *)title pageName:(NSString *)pageName language:(NSString *)language;

- (NSString *)resourcePath;

@end
