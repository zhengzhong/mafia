//
//  Created by ZHENG Zhong on 2014-03-20.
//  Copyright (c) 2014 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MafiaGameplayWebPageController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshBarButtonItem;

- (IBAction)refreshButtonTapped:(id)sender;

+ (instancetype)controller;

@end
