//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MafiaGameSetupAddPlayerController.h"


@class MafiaGameSetup;
@class MafiaGameSetupPlayersController;


@protocol MafiaGameSetupPlayersControllerDelegate <NSObject>

- (void)playersControllerDidComplete:(MafiaGameSetupPlayersController *)controller;

@end // MafiaGameSetupPlayersControllerDelegate


@interface MafiaGameSetupPlayersController : UITableViewController <MafiaGameSetupAddPlayerControllerDelegate>

@property (readonly, strong, nonatomic) MafiaGameSetup *gameSetup;
@property (readonly, weak, nonatomic) id<MafiaGameSetupPlayersControllerDelegate> delegate;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *doneButton;

+ (id)controllerWithGameSetup:(MafiaGameSetup *)gameSetup delegate:(id<MafiaGameSetupPlayersControllerDelegate>)delegate;

- (id)initWithGameSetup:(MafiaGameSetup *)gameSetup delegate:(id<MafiaGameSetupPlayersControllerDelegate>)delegate;

- (void)editTapped:(id)sender;

- (void)doneTapped:(id)sender;

@end // MafiaGameSetupPlayersController

