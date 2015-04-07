//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MafiaAddPlayerController;


@protocol MafiaAddPlayerControllerDelegate <NSObject>

- (void)addPlayerController:(MafiaAddPlayerController *)controller
       didAddPlayerWithName:(NSString *)name;

@end


@interface MafiaAddPlayerController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *playerNameField;
@property (weak, nonatomic) id<MafiaAddPlayerControllerDelegate> delegate;

- (IBAction)cancelBarButtonItemTapped:(id)sender;

- (IBAction)doneBarButtonItemTapped:(id)sender;

- (IBAction)backgroundTapped:(id)sender;

@end
