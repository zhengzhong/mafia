//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAddPlayerController.h"


@implementation MafiaAddPlayerController


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Add Player", nil);
    self.playerNameLabel.text = NSLocalizedString(@"Player Name", nil);
}


#pragma mark - IBAction


- (IBAction)cancelBarButtonItemTapped:(id)sender {
    [self.delegate addPlayerController:self didAddPlayerWithName:nil];
}



- (IBAction)doneBarButtonItemTapped:(id)sender {
    [self.delegate addPlayerController:self didAddPlayerWithName:self.playerNameField.text];
}


- (IBAction)backgroundTapped:(id)sender {
    // Make sure the text field resigns first responder and dismisses keyboard.
    [self.playerNameField resignFirstResponder];
}


@end
