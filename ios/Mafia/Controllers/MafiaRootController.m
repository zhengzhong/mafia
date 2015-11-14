//
//  Created by ZHENG Zhong on 2014-03-20.
//  Copyright (c) 2014 ZHENG Zhong. All rights reserved.
//

#import "MafiaRootController.h"
#import "MafiaGameSetupController.h"
#import "MafiaGameplayWebPageController.h"


@implementation MafiaRootController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Mafia", nil);
}

- (IBAction)newGameButtonTapped:(id)sender {
    UIViewController *controller = [MafiaGameSetupController controller];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)gameplayButtonTapped:(id)sender {
    UIViewController *controller = [MafiaGameplayWebPageController controller];
    [self.navigationController pushViewController:controller animated:YES];
}


@end
