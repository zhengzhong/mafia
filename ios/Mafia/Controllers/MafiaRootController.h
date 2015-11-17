//
//  Created by ZHENG Zhong on 2015-11-14.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MafiaRootController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *startNewGameButton;
@property (strong, nonatomic) IBOutlet UIButton *viewGameplayButton;
@property (strong, nonatomic) IBOutlet UIImageView *foregroundImageView;

- (IBAction)startNewGameButtonTapped:(id)sender;

- (IBAction)viewGameplayButtonTapped:(id)sender;

@end
