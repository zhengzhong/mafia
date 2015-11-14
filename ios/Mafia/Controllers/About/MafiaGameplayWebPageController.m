//
//  Created by ZHENG Zhong on 2014-03-20.
//  Copyright (c) 2014 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameplayWebPageController.h"


static NSString *const kStoryboard = @"About";
static NSString *const kControllerID = @"GameplayWebPageController";


static const NSString *kGameplayWebPageURLString = @"http://www.newsavour.com/disclaimer/";  // TODO: change URL.


@implementation MafiaGameplayWebPageController


#pragma mark - Storyboard


+ (instancetype)controller {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboard bundle:nil];
    MafiaGameplayWebPageController *controller = [storyboard instantiateViewControllerWithIdentifier:kControllerID];
    return controller;
}


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    [self mafia_loadWebPage];
}


#pragma mark - UIWebViewDelegate


- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.title = NSLocalizedString(@"Loading...", nil);
    self.refreshBarButtonItem.enabled = NO;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView.loading) {
        return;  // If the web view is still loading content, do nothing.
    }
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.refreshBarButtonItem.enabled = YES;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Failed to load web page from %@: %@", kGameplayWebPageURLString, error);
    if (webView.loading) {
        return;  // If the web view is still loading content, do nothing.
    }
    self.title = NSLocalizedString(@"Error Occurred", nil);
    self.refreshBarButtonItem.enabled = YES;
}


#pragma mark - Action


- (IBAction)refreshButtonTapped:(id)sender {
    if (!self.refreshBarButtonItem.enabled) {
        self.refreshBarButtonItem.enabled = YES;
        [self mafia_loadWebPage];
    }
}


#pragma mark - Private


- (void)mafia_loadWebPage {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL = [NSURL URLWithString:[kGameplayWebPageURLString copy]];
    NSLog(@"Loading web page from URL: %@", request.URL);
    [self.webView loadRequest:request];  // ???: Seems UIWebView cannot load a relative URL... Why?
}


@end
