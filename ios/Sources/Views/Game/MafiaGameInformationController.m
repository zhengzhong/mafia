//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameInformationController.h"

#import "../../Gameplay/MafiaGameplay.h"


@interface MafiaGameInformationController ()

- (void)presentWithAnimations;

- (void)bounceAnimationStopped;

@end // MafiaGameInformationController ()


@implementation MafiaGameInformationController


@synthesize categoryImageView = _categoryImageView;
@synthesize messageLabel = _messageLabel;
@synthesize detailsLabel = _detailsLabel;
@synthesize information = _information;
@synthesize delegate = _delegate;


+ (id)controllerWithDelegate:(id<MafiaGameInformationControllerDelegate>)delegate
{
    return [[[self alloc] initWithDelegate:delegate] autorelease];
}


- (void)dealloc
{
    [_categoryImageView release];
    [_messageLabel release];
    [_detailsLabel release];
    [_information release];
    [super dealloc];
}


- (id)initWithDelegate:(id<MafiaGameInformationControllerDelegate>)delegate
{
    if (self = [super initWithNibName:@"MafiaGameInformationController" bundle:nil])
    {
        _information = nil;
        _delegate = delegate;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)presentInformation:(MafiaInformation *)information inSuperview:(UIView *)superview
{
    [superview addSubview:self.view];
    self.information = information;
    NSString *categoryImageName = [NSString stringWithFormat:@"information_%@.png", self.information.category];
    self.categoryImageView.image = [UIImage imageNamed:categoryImageName];
    self.messageLabel.text = self.information.message;
    self.detailsLabel.text = [self.information.details componentsJoinedByString:@" * "];
    [self presentWithAnimations];
}


- (void)dismissInformationFromSuperview
{
    [self.view removeFromSuperview];
    self.information = nil;
}


- (IBAction)dismissButtonTapped:(id)sender
{
    [self.delegate informationControllerDidComplete:self];
}


#pragma mark - View animations


// I want to present a UIView with information like a UIAlert, with transaprent background.
// This cannot be implemented as a modal view because modal view will always hide the superview.
// So I have to implement animations myself to bring the view in.
//
// See: http://stackoverflow.com/questions/2600779/how-can-i-customize-an-ios-alert-view
//


- (void)presentWithAnimations
{
    self.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    self.view.alpha = 1.0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounceAnimationStopped)];
    self.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    [UIView commitAnimations];
}


- (void)bounceAnimationStopped
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    self.view.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}


@end // MafiaGameInformationController

