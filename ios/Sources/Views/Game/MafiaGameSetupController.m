//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetupController.h"
#import "MafiaGameSetupPlayersController.h"
#import "MafiaGameSetupRoleController.h"
#import "MafiaGamePlayController.h"

#import "../../Gameplay/MafiaGameplay.h"


enum MafiaGameSetupSections
{
    MafiaGameSetupPlayersSection = 0,
    MafiaGameSetupTwoHandedSection,
    MafiaGameSetupRolesSection,
    MafiaGameSetupNumberOfSections,
};


enum MafiaGameSetupRoleRows
{
    MafiaGameSetupNumberOfKillers = 0,
    MafiaGameSetupNumberOfDetectives,
    MafiaGameSetupHasAssassin,
    MafiaGameSetupHasGuardian,
    MafiaGameSetupHasDoctor,
    MafiaGameSetupHasTraitor,
    MafiaGameSetupHasUndercover,
    MafiaGameSetupNumberOfRoleRows,
};


@interface MafiaGameSetupController ()

- (UITableViewCell *)tableView:(UITableView *)tableView cellWithNumber:(NSInteger)number;

- (UITableViewCell *)tableView:(UITableView *)tableView cellWithSwitch:(BOOL)on target:(id)target action:(SEL)action tag:(NSInteger)tag;

- (UITableViewCell *)tableView:(UITableView *)tableView cellWithSwitch:(BOOL)on target:(id)target action:(SEL)action;

- (UITableViewCell *)tableView:(UITableView *)tableView cellWithRoleSwitch:(BOOL)on atIndexPath:(NSIndexPath *)indexPath;

@end // MafiaGameSetupController ()


@implementation MafiaGameSetupController


@synthesize gameSetup = _gameSetup;


+ (UIViewController *)controllerForTab
{
    MafiaGameSetupController *gameSetupController = [[[self alloc] initWithDefaultGameSetup] autorelease];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:gameSetupController] autorelease];
    navigationController.title = NSLocalizedString(@"Game", nil);
    navigationController.tabBarItem.image = [UIImage imageNamed:@"moon.png"];
    return navigationController;
}


- (void)dealloc
{
    [_gameSetup release];
    [super dealloc];
}


- (id)initWithDefaultGameSetup
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        _gameSetup = [[MafiaGameSetup alloc] init];
        // TODO: pre-initialize game setup for testing...
        NSArray *playerNames = [NSArray arrayWithObjects:@"雯雯", @"狼尼", @"小何", @"大叔", @"青青", @"老妖", nil];
        for (NSString *playerName in playerNames)
        {
            [_gameSetup addPlayerName:playerName];
        }
        _gameSetup.isTwoHanded = YES;
        self.title = NSLocalizedString(@"Game Setup", nil);
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    UIBarButtonItem *startButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Start", nil)
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(startGameTapped:)];
    startButton.enabled = [self.gameSetup isValid];
    self.navigationItem.rightBarButtonItem = startButton;
    [startButton release];
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
    return MafiaGameSetupNumberOfSections;
}


// Players section and two-handed section have only 1 row. Only roles section contains multiple rows.
// See: MafiaGameSetupRoleRows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == MafiaGameSetupRolesSection ? MafiaGameSetupNumberOfRoleRows : 1);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case MafiaGameSetupPlayersSection:
        {
            UITableViewCell *cell = [self tableView:tableView cellWithNumber:[self.gameSetup.playerNames count]];
            cell.imageView.image = [UIImage imageNamed:@"players.png"];
            cell.textLabel.text = NSLocalizedString(@"Players", nil);
            if ([self.gameSetup.playerNames count] >= [self.gameSetup numberOfPlayersRequired])
            {
                cell.detailTextLabel.textColor = [self darkGreenColor];
            }
            else
            {
                cell.detailTextLabel.textColor = [self darkRedColor];
            }
            return cell;
        }
        case MafiaGameSetupTwoHandedSection:
        {
            UITableViewCell *cell = [self tableView:tableView
                                     cellWithSwitch:self.gameSetup.isTwoHanded
                                             target:self
                                             action:@selector(twoHandedToggled:)];
            cell.imageView.image = [UIImage imageNamed:@"two_handed.png"];
            cell.textLabel.text = NSLocalizedString(@"Two Handed", nil);
            return cell;
        }
        case MafiaGameSetupRolesSection:
        {
            switch (indexPath.row)
            {
                case MafiaGameSetupNumberOfKillers:
                {
                    UITableViewCell *cell = [self tableView:tableView cellWithNumber:self.gameSetup.numberOfKillers];
                    cell.imageView.image = [UIImage imageNamed:@"role_killer.png"];
                    cell.textLabel.text = NSLocalizedString(@"Number of Killers", nil);
                    return cell;
                }
                case MafiaGameSetupNumberOfDetectives:
                {
                    UITableViewCell *cell = [self tableView:tableView cellWithNumber:self.gameSetup.numberOfDetectives];
                    cell.imageView.image = [UIImage imageNamed:@"role_detective.png"];
                    cell.textLabel.text = NSLocalizedString(@"Number of Detectives", nil);
                    return cell;
                }
                case MafiaGameSetupHasAssassin:
                {
                    UITableViewCell *cell = [self tableView:tableView cellWithRoleSwitch:self.gameSetup.hasAssassin atIndexPath:indexPath];
                    cell.imageView.image = [UIImage imageNamed:@"role_assassin.png"];
                    cell.textLabel.text = NSLocalizedString(@"Has Assassin", nil);
                    return cell;
                }
                case MafiaGameSetupHasGuardian:
                {
                    UITableViewCell *cell = [self tableView:tableView cellWithRoleSwitch:self.gameSetup.hasGuardian atIndexPath:indexPath];
                    cell.imageView.image = [UIImage imageNamed:@"role_guardian.png"];
                    cell.textLabel.text = NSLocalizedString(@"Has Guardian", nil);
                    return cell;
                }
                case MafiaGameSetupHasDoctor:
                {
                    UITableViewCell *cell = [self tableView:tableView cellWithRoleSwitch:self.gameSetup.hasDoctor atIndexPath:indexPath];
                    cell.imageView.image = [UIImage imageNamed:@"role_doctor.png"];
                    cell.textLabel.text = NSLocalizedString(@"Has Doctor", nil);
                    return cell;
                }
                case MafiaGameSetupHasTraitor:
                {
                    UITableViewCell *cell = [self tableView:tableView cellWithRoleSwitch:self.gameSetup.hasTraitor atIndexPath:indexPath];
                    cell.imageView.image = [UIImage imageNamed:@"role_traitor.png"];
                    cell.textLabel.text = NSLocalizedString(@"Has Traitor", nil);
                    return cell;
                }
                case MafiaGameSetupHasUndercover:
                {
                    UITableViewCell *cell = [self tableView:tableView cellWithRoleSwitch:self.gameSetup.hasUndercover atIndexPath:indexPath];
                    cell.imageView.image = [UIImage imageNamed:@"role_undercover.png"];
                    cell.textLabel.text = NSLocalizedString(@"Has Undercover", nil);
                    return cell;
                }
                default:
                {
                    return nil;
                }
            }
        }
        default:
        {
            return nil;
        }
    }
}


#pragma mark - Table view delegate



- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case MafiaGameSetupPlayersSection:
        {
            return indexPath;
        }
        case MafiaGameSetupTwoHandedSection:
        {
            return nil;
        }
        case MafiaGameSetupRolesSection:
        {
            if (indexPath.row == MafiaGameSetupNumberOfKillers || indexPath.row == MafiaGameSetupNumberOfDetectives)
            {
                return indexPath;
            }
            else
            {
                return nil;
            }
        }
        default:
        {
            return nil;
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == MafiaGameSetupPlayersSection)
    {
        UIViewController *playersController = [MafiaGameSetupPlayersController controllerWithGameSetup:self.gameSetup delegate:self];
        [self.navigationController pushViewController:playersController animated:YES];
    }
    else if (indexPath.section == MafiaGameSetupRolesSection)
    {
        if (indexPath.row == MafiaGameSetupNumberOfKillers)
        {
            UIViewController *roleController = [MafiaGameSetupRoleController
                                                controllerWithRole:[MafiaRole killer]
                                                minValue:1
                                                maxValue:4
                                                value:self.gameSetup.numberOfKillers
                                                delegate:self];
            [self.navigationController pushViewController:roleController animated:YES];
        }
        else if (indexPath.row == MafiaGameSetupNumberOfDetectives)
        {
            UIViewController *roleController = [MafiaGameSetupRoleController
                                                controllerWithRole:[MafiaRole detective]
                                                minValue:1
                                                maxValue:4
                                                value:self.gameSetup.numberOfDetectives
                                                delegate:self];
            [self.navigationController pushViewController:roleController animated:YES];
        }
    }
}


#pragma mark - Actions


- (void)twoHandedToggled:(id)sender
{
    self.gameSetup.isTwoHanded = ((UISwitch *) sender).on;
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = [self.gameSetup isValid];
}


- (void)roleSwitchToggled:(id)sender
{
    UISwitch *roleSwitch = (UISwitch *) sender;
    switch (roleSwitch.tag)
    {
        case MafiaGameSetupHasAssassin:
        {
            self.gameSetup.hasAssassin = roleSwitch.on;
            break;
        }
        case MafiaGameSetupHasGuardian:
        {
            self.gameSetup.hasGuardian = roleSwitch.on;
            break;
        }
        case MafiaGameSetupHasDoctor:
        {
            self.gameSetup.hasDoctor = roleSwitch.on;
            break;
        }
        case MafiaGameSetupHasTraitor:
        {
            self.gameSetup.hasTraitor = roleSwitch.on;
            break;
        }
        case MafiaGameSetupHasUndercover:
        {
            self.gameSetup.hasUndercover = roleSwitch.on;
            break;
        }
        default:
        {
            break;
        }
    }
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = [self.gameSetup isValid];
}


- (void)startGameTapped:(id)sender
{
    if ([self.gameSetup isValid])
    {
        UIViewController *playController = [MafiaGamePlayController controllerWithGameSetup:self.gameSetup];
        [self.navigationController pushViewController:playController animated:YES];
    }
}


#pragma mark - MafiaGameSetupPlayersDelegate


- (void)playersControllerDidComplete:(MafiaGameSetupPlayersController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = [self.gameSetup isValid];
}


#pragma mark - MafiaGameSetupRoleDelegate


- (void)roleController:(MafiaGameSetupRoleController *)controller didSelectValue:(NSInteger)value forRole:(MafiaRole *)role
{
    if (role == [MafiaRole killer])
    {
        self.gameSetup.numberOfKillers = value;
    }
    else if (role == [MafiaRole detective])
    {
        self.gameSetup.numberOfDetectives = value;
    }
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = [self.gameSetup isValid];
}


#pragma mark - Private methods to create table view cells


- (UIColor *)darkGreenColor
{
    return [UIColor colorWithRed:0.27 green:0.53 blue:0.28 alpha:1.0];
}


- (UIColor *)darkRedColor
{
    return [UIColor colorWithRed:0.73 green:0.29 blue:0.28 alpha:1.0];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellWithNumber:(NSInteger)number
{
    static NSString *CellIdentifier = @"MafiaGameSetupCellWithNumber";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", number];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellWithSwitch:(BOOL)on target:(id)target action:(SEL)action tag:(NSInteger)tag
{
    static NSString *CellIdentifier = @"MafiaGameSetupCellWithSwitch";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    // TODO: maybe we could reuse the UISwitch if it exists.
    UISwitch *switchInCell = [[[UISwitch alloc] init] autorelease];
    switchInCell.on = on;
    [switchInCell addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    switchInCell.tag = tag;
    cell.accessoryView = [[[UIView alloc] initWithFrame:switchInCell.frame] autorelease];
    [cell.accessoryView addSubview:switchInCell];
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellWithSwitch:(BOOL)on target:(id)target action:(SEL)action
{
    return [self tableView:tableView cellWithSwitch:on target:target action:action tag:-1];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellWithRoleSwitch:(BOOL)on atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(indexPath.section == MafiaGameSetupRolesSection, @"Invalid section in indexPath for role switch.");
    UITableViewCell *cell = [self tableView:tableView cellWithSwitch:on target:self action:@selector(roleSwitchToggled:) tag:indexPath.row];
    return cell;
}


@end // MafiaGameSetupController

