//
//  Created by ZHENG Zhong on 2014-03-20.
//  Copyright (c) 2014 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameplayWebPageController.h"
#import "UINavigationItem+MafiaBackTitle.h"

#import "SVProgressHUD.h"


static NSString *const kStoryboard = @"About";
static NSString *const kControllerID = @"GameplayWebPageController";


static const NSString *kGameplayWebPageURLString = @"http://www.zhengzhong.net/mafia/gameplay/";


@implementation MafiaGameplayWebPageController


#pragma mark - Storyboard


+ (instancetype)controller {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboard bundle:nil];
    MafiaGameplayWebPageController *controller = [storyboard instantiateViewControllerWithIdentifier:kControllerID];
    return controller;
}


#pragma mark - Lifecycle


- (void)dealloc {
    self.webView.delegate = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem mafia_clearBackTitle];
    self.title = NSLocalizedString(@"Loading...", nil);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self mafia_loadWebPage];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self mafia_stopLoadingWebPage];
}


#pragma mark - UIWebViewDelegate


- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (![SVProgressHUD isVisible]) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", nil)];
    }
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView.loading) {
        return;  // If the web view is still loading content, do nothing.
    }
    self.title = NSLocalizedString(@"Gameplay", nil);
    [SVProgressHUD dismiss];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Failed to load web page from %@: %@", kGameplayWebPageURLString, error);
    if (webView.loading) {
        return;  // If the web view is still loading content, do nothing.
    }
    self.title = NSLocalizedString(@"Error Occurred", nil);
    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
}


#pragma mark - Action


- (IBAction)refreshButtonTapped:(id)sender {
    [self mafia_stopLoadingWebPage];
    [self mafia_loadWebPage];
}


#pragma mark - Private


- (void)mafia_loadWebPage {
    self.title = NSLocalizedString(@"Loading...", nil);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL = [NSURL URLWithString:[kGameplayWebPageURLString copy]];
    NSLog(@"Loading web page from URL: %@", request.URL);
    [self.webView loadRequest:request];
}


- (void)mafia_stopLoadingWebPage {
    if (self.webView.loading) {
        [self.webView stopLoading];
    }
    [SVProgressHUD dismiss];
}


@end
