//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MafiaGameSetupAddPlayerController;


@protocol MafiaGameSetupAddPlayerDelegate <NSObject>

- (void)addPlayerController:(MafiaGameSetupAddPlayerController *)controller didAddPlayer:(NSString *)name;

@end // MafiaGameSetupAddPlayerDelegate


@interface MafiaGameSetupAddPlayerController : UIViewController

@property (retain, nonatomic) IBOutlet UITextField *playerNameField;
@property (readonly, assign, nonatomic) id<MafiaGameSetupAddPlayerDelegate> delegate;

+ (id)controllerWithDelegate:(id<MafiaGameSetupAddPlayerDelegate>)delegate;

- (id)initWithDelegate:(id<MafiaGameSetupAddPlayerDelegate>)delegate;

- (void)cancelTapped:(id)sender;

- (void)doneTapped:(id)sender;

@end // MafiaGameSetupAddPlayerController

