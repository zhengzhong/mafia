//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//
#import <UIKit/UIKit.h>
@class MafiaHTMLPage;


@interface MafiaHTMLPageController : UIViewController

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (readonly, retain, nonatomic) MafiaHTMLPage *htmlPage;

+ (id)controllerWithHTMLPage:(MafiaHTMLPage *)htmlPage;

- (id)initWithHTMLPage:(MafiaHTMLPage *)htmlPage;

@end // MafiaHTMLPageController

