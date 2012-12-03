//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MafiaGameSetupAddPlayerController.h"


@class MafiaGameSetup;
@class MafiaGameSetupPlayersController;


@protocol MafiaGameSetupPlayersDelegate <NSObject>

- (void)playersControllerDidComplete:(MafiaGameSetupPlayersController *)controller;

@end // MafiaGameSetupPlayersDelegate


@interface MafiaGameSetupPlayersController : UITableViewController <MafiaGameSetupAddPlayerDelegate>

@property (readonly, retain, nonatomic) MafiaGameSetup *gameSetup;
@property (readonly, assign, nonatomic) id<MafiaGameSetupPlayersDelegate> delegate;
@property (retain, nonatomic) UIBarButtonItem *editButton;
@property (retain, nonatomic) UIBarButtonItem *doneButton;

+ (id)controllerWithGameSetup:(MafiaGameSetup *)gameSetup delegate:(id<MafiaGameSetupPlayersDelegate>)delegate;

- (id)initWithGameSetup:(MafiaGameSetup *)gameSetup delegate:(id<MafiaGameSetupPlayersDelegate>)delegate;

- (void)editTapped:(id)sender;

- (void)doneTapped:(id)sender;

@end // MafiaGameSetupPlayersController

