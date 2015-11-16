//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAutonomicGameController.h"
#import "MafiaAutonomicActionController.h"
#import "TSMessage+MafiaAdditions.h"
#import "UIImage+MafiaAdditions.h"

#import "MafiaAssets.h"
#import "MafiaGameplay.h"
#import "UIView+MafiaAdditions.h"


@implementation MafiaAutonomicGameActionCell

- (void)setupWithAction:(MafiaAction *)action isCurrent:(BOOL)isCurrent {
    if (action.player != nil) {
        UIImage *avatarImage = action.player.avatarImage;
        if (avatarImage == nil) {
            avatarImage = [MafiaAssets imageOfAvatar:MafiaAvatarDefault];
        }
        if (action.player.isDead) {
            avatarImage = [avatarImage mafia_grayscaledImage];
        }
        self.actionImageView.image = avatarImage;
    } else {
        // Action does not have a player.
        self.actionImageView.image = [MafiaAssets imageOfAvatar:MafiaAvatarInfo];
    }
    [self.actionImageView mafia_makeRoundCornersWithBorder:NO];

    self.actionNameLabel.text = action.displayName;
    if (isCurrent) {
        self.actionNameLabel.textColor = [UIColor blackColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.actionNameLabel.textColor = [UIColor lightGrayColor];
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end


// ------------------------------------------------------------------------------------------------


static NSString *const kStoryboard = @"AutonomicGame";
static NSString *const kControllerID = @"AutonomicGame";


static NSString *const kSegueStartAction = @"StartAction";

static NSString *const kActionCellID = @"ActionCell";


@interface MafiaAutonomicGameController () <MafiaAuthnomicActionControllerDelegate>

@end


@implementation MafiaAutonomicGameController


#pragma mark - Storyboard


+ (instancetype)controller {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboard bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:kControllerID];
}


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Enable auto-sizing table view cell.
    self.tableView.estimatedRowHeight = 65;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}


#pragma mark - Public Methods


- (void)startGame:(MafiaGame *)game {
    NSAssert(game.gameSetup.isAutonomic, @"This controller only accepts autonomic game.");
    self.game = game;
    [self.game startGame];
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0 ? [self.game.actions count] : 0);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row < [self.game.actions count]) {
        MafiaAction *action = self.game.actions[indexPath.row];
        BOOL isCurrent = (action == [self.game currentAction]);
        MafiaAutonomicGameActionCell *cell = [tableView dequeueReusableCellWithIdentifier:kActionCellID forIndexPath:indexPath];
        [cell setupWithAction:action isCurrent:isCurrent];
        return cell;
    }
    return nil;
}


#pragma mark - UITableViewDelegate


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row < [self.game.actions count]) {
        MafiaAction *action = self.game.actions[indexPath.row];
        if (action == [self.game currentAction]) {
            return indexPath;
        }
    }
    return nil;
}


#pragma mark - MafiaAuthnomicActionControllerDelegate


- (void)autonomicActionControllerDidCompleteAction:(UIViewController *)controller {
    // The current action is complete, and we are about to continue to the next action.
    [self.game continueToNextAction];
    [self.navigationController popViewControllerAnimated:YES];
    [self mafia_refreshUI];
}


#pragma mark - Actions


- (IBAction)resetButtonTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(@"Are you sure to reset game?", nil)
                         message:nil
                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No. Take me back!", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];

    void (^resetGameBlock)(UIAlertAction *) = ^(UIAlertAction *action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    };
    UIAlertAction *resetGameAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes. Reset the game!", nil)
                                                              style:UIAlertActionStyleDestructive
                                                            handler:resetGameBlock];
    [alertController addAction:resetGameAction];

    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueStartAction]) {
        MafiaAutonomicActionController *controller = segue.destinationViewController;
        controller.delegate = self;
        [controller setupWithGame:self.game];
    }
}


#pragma mark - Private Methods


- (void)mafia_refreshUI {
    if (self.game.winner != MafiaWinnerUnknown) {
        self.title = NSLocalizedString(@"Game Over", nil);
        [TSMessage mafia_showGameResultWithWinner:self.game.winner];
    }
    [self.tableView reloadData];
}


@end
