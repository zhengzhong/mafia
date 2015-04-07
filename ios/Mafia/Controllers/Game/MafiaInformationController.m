//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaInformationController.h"

#import "MafiaGameplay.h"


@implementation MafiaInformationController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *categoryImageName = [NSString stringWithFormat:@"information_%@.png", self.information.category];
    self.categoryImageView.image = [UIImage imageNamed:categoryImageName];
    self.messageLabel.text = self.information.message;
    self.detailsLabel.text = [self.information.details componentsJoinedByString:@" * "];
}


- (IBAction)dismissButtonTapped:(id)sender {
    [self.delegate informationControllerDidComplete:self];
}


@end
