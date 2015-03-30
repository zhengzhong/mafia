//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaHTMLPage.h"

@implementation MafiaHTMLPage

@synthesize title = _title;
@synthesize pageName = _pageName;
@synthesize language = _language;

+ (id)pageWithTitle:(NSString *)title pageName:(NSString *)pageName language:(NSString *)language
{
    return [[self alloc] initWithTitle:title pageName:pageName language:language];
}

- (id)initWithTitle:(NSString *)title pageName:(NSString *)pageName language:(NSString *)language
{
    if (self = [super init])
    {
        _title = [title copy];
        _pageName = [pageName copy];
        _language = [language copy];
    }
    return self;
}

- (NSString *)resourcePath
{
    NSString *resourceName = [NSString stringWithFormat:@"%@.%@", self.pageName, self.language];
    return [[NSBundle mainBundle] pathForResource:resourceName ofType:@"html"];
}

@end // MafiaHTMLPage

