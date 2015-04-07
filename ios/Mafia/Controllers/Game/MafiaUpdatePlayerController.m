//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaUpdatePlayerController.h"

#import "MafiaUpdatePlayerRoleController.h"

#import "MafiaGameplay.h"


@implementation MafiaPlayerStatus


+ (instancetype)statusWithName:(NSString *)name
                     imageName:(NSString *)imageName
                           key:(NSString *)key
                         value:(BOOL)value {
    return [[self alloc] initWithName:name imageName:imageName key:key value:value];
}


- (instancetype)initWithName:(NSString *)name
                   imageName:(NSString *)imageName
                         key:(NSString *)key
                       value:(BOOL)value {
    if (self = [super init]) {
        _name = [name copy];
        _imageName = [imageName copy];
        _key = [key copy];
        _value = value;
    }
    return self;
}


@end  //  MafiaPlayerStatus



@implementation MafiaPlayerStatusCell


- (IBAction)switchToggled:(id)sender {
    self.status.value = self.valueSwitch.on;
}


- (void)refresh {
    self.imageView.image = [UIImage imageNamed:self.status.imageName];
    self.textLabel.text = self.status.name;
    self.valueSwitch.on = self.status.value;
}


@end  // MafiaPlayerStatusCell


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
    self.title = self.player.name;
    // Bind statuses to cells.
    self.deadStatusCell.status = self.deadStatus;
    self.misdiagnosedStatusCell.status = self.misdiagnosedStatus;
    self.justGuardedStatusCell.status = self.justGuardedStatus;
    self.unguardableStatusCell.status = self.unguardableStatus;
    self.votedStatusCell.status = self.votedStatus;
    // Refresh cells.
    self.roleCell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"role_%@.png", self.role.name]];
    self.roleCell.textLabel.text = self.role.displayName;
    [self.deadStatusCell refresh];
    [self.misdiagnosedStatusCell refresh];
    [self.justGuardedStatusCell refresh];
    [self.unguardableStatusCell refresh];
    [self.votedStatusCell refresh];
}


#pragma mark - Public Methods


- (void)loadPlayer:(MafiaPlayer *)player {
    self.player = player;
    self.role = player.role;
    self.deadStatus = [MafiaPlayerStatus
        statusWithName:NSLocalizedString(@"Dead?", nil)
             imageName:@"is_dead.png"
                   key:@"isDead"
                 value:player.isDead];
    self.misdiagnosedStatus = [MafiaPlayerStatus
        statusWithName:NSLocalizedString(@"Misdiagnosed?", nil)
             imageName:@"is_misdiagnosed.png"
                   key:@"isMisdiagnosed"
                 value:player.isMisdiagnosed];
    self.justGuardedStatus = [MafiaPlayerStatus
        statusWithName:NSLocalizedString(@"Just Guarded?", nil)
             imageName:@"is_just_guarded.png"
                   key:@"isJustGuarded"
                 value:player.isJustGuarded];
    self.unguardableStatus = [MafiaPlayerStatus
        statusWithName:NSLocalizedString(@"Unguardable?", nil)
             imageName:@"is_unguardable.png"
                   key:@"isUnguardable"
                 value:player.isUnguardable];
    self.votedStatus = [MafiaPlayerStatus
        statusWithName:NSLocalizedString(@"Voted?", nil)
             imageName:@"is_voted.png"
                   key:@"isVoted"
                 value:player.isVoted];
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
        self.deadStatus,
        self.misdiagnosedStatus,
        self.justGuardedStatus,
        self.unguardableStatus,
        self.votedStatus,
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
