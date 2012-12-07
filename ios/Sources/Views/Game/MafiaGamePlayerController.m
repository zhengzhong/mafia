//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGamePlayerController.h"
#import "MafiaGamePlayerRoleController.h"

#import "../../Gameplay/MafiaGameplay.h"


enum MafiaGamePlayerSections
{
    MafiaGamePlayerRoleSection = 0,
    MafiaGamePlayerStatusSection,
    MafiaGamePlayerNumberOfSections,
};


enum MafiaGamePlayerStatus
{
    MafiaGamePlayerDeadStatus = 0,
    MafiaGamePlayerMisdiagnosedStatus,
    MafiaGamePlayerJustGuardedStatus,
    MafiaGamePlayerUnguardableStatus,
    MafiaGamePlayerVotedStatus,
    MafiaGamePlayerNumberOfStatus,
};


@implementation MafiaGamePlayerStatus

@synthesize name = _name;
@synthesize imageName = _imageName;
@synthesize key = _key;
@synthesize value = _value;

+ (id)statusWithName:(NSString *)name imageName:(NSString *)imageName key:(NSString *)key value:(BOOL)value
{
    return [[[self alloc] initWithName:name imageName:imageName key:key value:value] autorelease];
}

- (void)dealloc
{
    [_name release];
    [_imageName release];
    [_key release];
    [super dealloc];
}

- (id)initWithName:(NSString *)name imageName:(NSString *)imageName key:(NSString *)key value:(BOOL)value
{
    if (self = [super init])
    {
        _name = [name copy];
        _imageName = [imageName copy];
        _key = [key copy];
        _value = value;
    }
    return self;
}

@end // MafiaGamePlayerStatus


@interface MafiaGamePlayerController ()

- (UITableViewCell *)tableView:(UITableView *)tableView roleCellAtIndexPath:(NSIndexPath *)indexPath;

- (UITableViewCell *)tableView:(UITableView *)tableView statusCellAtIndexPath:(NSIndexPath *)indexPath;

@end // MafiaGamePlayerController ()


@implementation MafiaGamePlayerController


@synthesize player = _player;
@synthesize role = _role;
@synthesize statuses = _statuses;
@synthesize delegate = _delegate;


+ (id)controllerWithPlayer:(MafiaPlayer *)player delegate:(id<MafiaGamePlayerControllerDelegate>)delegate
{
    return [[[self alloc] initWithPlayer:player delegate:delegate] autorelease];
}


- (void)dealloc
{
    [_player release];
    [_role release];
    [_statuses release];
    [super dealloc];
}


- (id)initWithPlayer:(MafiaPlayer *)player delegate:(id<MafiaGamePlayerControllerDelegate>)delegate
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        _player = [player retain];
        _role = [player.role retain];
        _statuses = [[NSArray alloc] initWithObjects:
                     [MafiaGamePlayerStatus statusWithName:@"Dead?" imageName:@"is_dead.png" key:@"isDead" value:player.isDead],
                     [MafiaGamePlayerStatus statusWithName:@"Misdiagnosed?" imageName:@"is_misdiagnosed.png" key:@"isMisdiagnosed" value:player.isMisdiagnosed],
                     [MafiaGamePlayerStatus statusWithName:@"Just Guarded?" imageName:@"is_just_guarded.png" key:@"isJustGuarded" value:player.isJustGuarded],
                     [MafiaGamePlayerStatus statusWithName:@"Unguardable?" imageName:@"is_unguardable.png" key:@"isUnguardable" value:player.isUnguardable],
                     [MafiaGamePlayerStatus statusWithName:@"Voted?" imageName:@"is_voted.png" key:@"isVoted" value:player.isVoted],
                     nil];
        _delegate = delegate;
        self.title = player.name;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
    [self.navigationItem setHidesBackButton:YES animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MafiaGamePlayerNumberOfSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == MafiaGamePlayerStatusSection ? MafiaGamePlayerNumberOfStatus : 1);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == MafiaGamePlayerRoleSection)
    {
        return [self tableView:tableView roleCellAtIndexPath:indexPath];
    }
    else if (indexPath.section == MafiaGamePlayerStatusSection)
    {
        return [self tableView:tableView statusCellAtIndexPath:indexPath];
    }
    else
    {
        return nil;
    }
}


#pragma mark - Table view delegate


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == MafiaGamePlayerRoleSection ? indexPath : nil);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == MafiaGamePlayerRoleSection)
    {
        MafiaGamePlayerRoleController *playerRoleController = [MafiaGamePlayerRoleController controllerWithRole:self.role delegate:self];
        [self.navigationController pushViewController:playerRoleController animated:YES];
    }
}


#pragma mark - MafiaGamePlayerRoleControllerDelegate


- (void)playerRoleController:(MafiaGamePlayerRoleController *)controller didCompleteWithRole:(MafiaRole *)role
{
    self.role = role;
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
}


#pragma mark - Status Cell Actions


- (void)statusToggled:(id)sender
{
    UISwitch *statusSwitch = (UISwitch *) sender;
    MafiaGamePlayerStatus *status = [self.statuses objectAtIndex:statusSwitch.tag];
    status.value = statusSwitch.on;
    [self.tableView reloadData];
}


#pragma mark - UIBarButtonItem actions


- (void)doneTapped:(id)sender
{
    self.player.role = self.role;
    for (MafiaGamePlayerStatus *status in self.statuses)
    {
        [self.player setValue:[NSNumber numberWithBool:status.value] forKey:status.key];
    }
    [self.delegate playerController:self didCompleteWithPlayer:self.player];
}


- (void)cancelTapped:(id)sender
{
    [self.delegate playerController:self didCompleteWithPlayer:self.player];
}


#pragma mark - Private methods


- (UITableViewCell *)tableView:(UITableView *)tableView roleCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(indexPath.section == MafiaGamePlayerRoleSection, @"Invalid index path for player status cell.");
    static NSString *CellIdentifier = @"MafiaGamePlayerRoleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"role_%@.png", [self.role.name lowercaseString]]];
    cell.textLabel.text = self.role.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView statusCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(indexPath.section == MafiaGamePlayerStatusSection, @"Invalid index path for player status cell.");
    static NSString *CellIdentifier = @"MafiaGamePlayerStatusCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    MafiaGamePlayerStatus *status = [self.statuses objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:status.imageName];
    cell.textLabel.text = status.name;
    // TODO: maybe we could reuse the UISwitch if it exists.
    UISwitch *statusSwitch = [[[UISwitch alloc] init] autorelease];
    statusSwitch.on = status.value;
    [statusSwitch addTarget:self action:@selector(statusToggled:) forControlEvents:UIControlEventTouchUpInside];
    statusSwitch.tag = indexPath.row;
    cell.accessoryView = [[[UIView alloc] initWithFrame:statusSwitch.frame] autorelease];
    [cell.accessoryView addSubview:statusSwitch];
    return cell;
}


@end // MafiaGamePlayerController

