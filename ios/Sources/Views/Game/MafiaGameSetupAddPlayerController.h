//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>


@class MafiaGameSetupAddPlayerController;


@protocol MafiaGameSetupAddPlayerControllerDelegate <NSObject>

- (void)addPlayerController:(MafiaGameSetupAddPlayerController *)controller didAddPlayer:(NSString *)name;

@end // MafiaGameSetupAddPlayerControllerDelegate


@interface MafiaGameSetupAddPlayerController : UIViewController <ABPeoplePickerNavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *playerNameField;
@property (readonly, weak, nonatomic) id<MafiaGameSetupAddPlayerControllerDelegate> delegate;

+ (id)controllerWithDelegate:(id<MafiaGameSetupAddPlayerControllerDelegate>)delegate;

- (id)initWithDelegate:(id<MafiaGameSetupAddPlayerControllerDelegate>)delegate;

- (void)cancelTapped:(id)sender;

- (IBAction)doneTapped:(id)sender;

- (IBAction)showContactPicker:(id)sender;

- (IBAction)backgroundTapped:(id)sender;

@end // MafiaGameSetupAddPlayerController

