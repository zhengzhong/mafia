//
//  Created by ZHENG Zhong on 2015-04-22.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaLoadGameSetupController;
@class MafiaGameSetup;


@protocol MafiaLoadGameSetupControllerDelegate <NSObject>

- (void)loadGameSetupController:(MafiaLoadGameSetupController *)controller
               didLoadGameSetup:(MafiaGameSetup *)gameSetup;

- (void)loadGameSetupControllerDidCancel:(MafiaLoadGameSetupController *)controller;

@end


@interface MafiaLoadGameSetupController : UITableViewController

@property (weak, nonatomic) id<MafiaLoadGameSetupControllerDelegate> delegate;

- (IBAction)cancelButtonTapped:(id)sender;

- (IBAction)editButtonTapped:(id)sender;

@end
