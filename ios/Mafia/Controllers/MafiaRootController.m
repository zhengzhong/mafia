//
//  Created by ZHENG Zhong on 2014-03-20.
//  Copyright (c) 2014 ZHENG Zhong. All rights reserved.
//

#import "MafiaRootController.h"
#import "MafiaGameSetupController.h"
#import "MafiaGameplayWebPageController.h"

#import "UINavigationItem+MafiaBackTitle.h"
#import "UIView+MafiaAdditions.h"


@implementation MafiaRootController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem mafia_clearBackTitle];
    self.title = NSLocalizedString(@"Mafia", nil);

    [self.startNewGameButton setTitle:NSLocalizedString(@"New Game", nil) forState:UIControlStateNormal];
    [self.viewGameplayButton setTitle:NSLocalizedString(@"Gameplay", nil) forState:UIControlStateNormal];
    [self.startNewGameButton mafia_makeRoundCornersWithBorder:YES];
    [self.viewGameplayButton mafia_makeRoundCornersWithBorder:YES];
    [self.view bringSubviewToFront:self.foregroundImageView];
}

- (IBAction)startNewGameButtonTapped:(id)sender {
    UIViewController *controller = [MafiaGameSetupController controller];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)viewGameplayButtonTapped:(id)sender {
    UIViewController *controller = [MafiaGameplayWebPageController controller];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
