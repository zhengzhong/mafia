//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaUpdatePlayerController.h"
#import "MafiaUpdatePlayerRoleController.h"

#import "MafiaAssets.h"
#import "MafiaGameplay.h"


@implementation MafiaPlayerStatus

- (instancetype)initWithKey:(NSString *)key value:(BOOL)value {
    if (self = [super init]) {
        _key = [key copy];
        _value = value;
    }
    return self;
}

@end


@implementation MafiaPlayerStatusCell

- (IBAction)switchToggled:(id)sender {
    self.status.value = self.valueSwitch.on;
}

- (void)refresh {
    self.valueSwitch.on = self.status.value;
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

    // Bind statuses to cells.
    self.justGuardedStatusCell.status = self.justGuardedStatus;
    self.unguardableStatusCell.status = self.unguardableStatus;
    self.misdiagnosedStatusCell.status = self.misdiagnosedStatus;
    self.votedStatusCell.status = self.votedStatus;
    self.deadStatusCell.status = self.deadStatus;

    // Refresh cells.
    self.roleCell.imageView.image = [MafiaAssets imageOfRole:self.role];
    self.roleCell.textLabel.text = self.role.displayName;
    [self.justGuardedStatusCell refresh];
    [self.unguardableStatusCell refresh];
    [self.misdiagnosedStatusCell refresh];
    [self.votedStatusCell refresh];
    [self.deadStatusCell refresh];
}


#pragma mark - Public


- (void)loadPlayer:(MafiaPlayer *)player {
    self.player = player;
    self.role = player.role;
    self.justGuardedStatus = [[MafiaPlayerStatus alloc] initWithKey:@"isJustGuarded" value:player.isJustGuarded];
    self.unguardableStatus = [[MafiaPlayerStatus alloc] initWithKey:@"isUnguardable" value:player.isUnguardable];
    self.misdiagnosedStatus = [[MafiaPlayerStatus alloc] initWithKey:@"isMisdiagnosed" value:player.isMisdiagnosed];
    self.votedStatus = [[MafiaPlayerStatus alloc] initWithKey:@"isVoted" value:player.isVoted];
    self.deadStatus = [[MafiaPlayerStatus alloc] initWithKey:@"isDead" value:player.isDead];
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UpdatePlayerRole"]) {
        MafiaUpdatePlayerRoleController *controller = segue.destinationViewController;
        [controller setRole:self.role];
        controller.delegate = self;
    }
}


#pragma mark - Actions


- (IBAction)cancelButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)doneButtonTapped:(id)sender {
    self.player.role = self.role;
    NSArray *statuses = @[
        self.justGuardedStatus,
        self.unguardableStatus,
        self.misdiagnosedStatus,
        self.votedStatus,
        self.deadStatus,
    ];
    for (MafiaPlayerStatus *status in statuses) {
        [self.player setValue:@(status.value) forKey:status.key];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - MafiaUpdatePlayerRoleControllerDelegate


- (void)updatePlayerRoleController:(UIViewController *)controller didUpdateRole:(MafiaRole *)role {
    self.role = role;
}


@end
