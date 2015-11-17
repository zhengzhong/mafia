//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaUpdatePlayerController.h"
#import "MafiaUpdatePlayerRoleController.h"

#import "MafiaAssets.h"
#import "MafiaGameplay.h"


@implementation MafiaUpdatePlayerRoleCell

- (void)setupWithRole:(MafiaRole *)role {
    self.role = role;
    self.imageView.image = [MafiaAssets imageOfRole:role];
    self.textLabel.text = role.displayName;
}

@end


@implementation MafiaUpdatePlayerStatusCell

- (void)setupWithPlayer:(MafiaPlayer *)player statusKey:(NSString *)statusKey {
    self.player = player;
    self.statusKey = statusKey;
    self.statusValue = [[self.player valueForKey:self.statusKey] boolValue];
    self.valueSwitch.on = self.statusValue;
}

- (IBAction)switchToggled:(id)sender {
    self.statusValue = self.valueSwitch.on;
}

@end


// ------------------------------------------------------------------------------------------------


@interface MafiaUpdatePlayerController () <MafiaUpdatePlayerRoleControllerDelegate>

@end


@implementation MafiaUpdatePlayerController


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.player.displayName;
    [self.roleCell setupWithRole:self.updatedRole];
    [self.justGuardedStatusCell setupWithPlayer:self.player statusKey:@"isJustGuarded"];
    [self.unguardableStatusCell setupWithPlayer:self.player statusKey:@"isUnguardable"];
    [self.misdiagnosedStatusCell setupWithPlayer:self.player statusKey:@"isMisdiagnosed"];
    [self.votedStatusCell setupWithPlayer:self.player statusKey:@"isVoted"];
    [self.deadStatusCell setupWithPlayer:self.player statusKey:@"isDead"];
}


#pragma mark - Public


- (void)setupWithPlayer:(MafiaPlayer *)player {
    self.player = player;
    self.updatedRole = player.role;
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UpdatePlayerRole"]) {
        MafiaUpdatePlayerRoleController *controller = segue.destinationViewController;
        [controller setRole:self.updatedRole];
        controller.delegate = self;
    }
}


#pragma mark - Actions


- (IBAction)cancelButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)doneButtonTapped:(id)sender {
    self.player.role = self.updatedRole;
    self.player.isJustGuarded = self.justGuardedStatusCell.statusValue;
    self.player.isUnguardable = self.unguardableStatusCell.statusValue;
    self.player.isMisdiagnosed = self.misdiagnosedStatusCell.statusValue;
    self.player.isVoted = self.votedStatusCell.statusValue;
    self.player.isDead = self.deadStatusCell.statusValue;
    [self.delegate updatePlayerController:self didUpdatePlayer:self.player];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - MafiaUpdatePlayerRoleControllerDelegate


- (void)updatePlayerRoleController:(UIViewController *)controller didUpdateRole:(MafiaRole *)role {
    self.updatedRole = role;
}


@end
