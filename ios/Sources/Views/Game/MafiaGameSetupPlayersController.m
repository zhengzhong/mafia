//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetupPlayersController.h"
#import "MafiaGameSetupAddPlayerController.h"

#import "../../Gameplay/MafiaGameplay.h"


enum MafiaGameSetupPlayersSections
{
    MafiaGameSetupPlayersListSection = 0,
    MafiaGameSetupPlayersAddSection,
    MafiaGameSetupPlayersNumberOfSections,
};


@implementation MafiaGameSetupPlayersController


@synthesize gameSetup = _gameSetup;
@synthesize delegate = _delegate;
@synthesize editButton = _editButton;
@synthesize doneButton = _doneButton;


+ (id)controllerWithGameSetup:(MafiaGameSetup *)gameSetup delegate:(id<MafiaGameSetupPlayersControllerDelegate>)delegate
{
    return [[[self alloc] initWithGameSetup:gameSetup delegate:delegate] autorelease];
}


- (void)dealloc
{
    [_gameSetup release];
    [_editButton release];
    [_doneButton release];
    [super dealloc];
}


- (id)initWithGameSetup:(MafiaGameSetup *)gameSetup delegate:(id<MafiaGameSetupPlayersControllerDelegate>)delegate
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        _gameSetup = [gameSetup retain];
        _delegate = delegate;
        _editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editTapped:)];
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
        self.title = @"Players";
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    self.navigationItem.leftBarButtonItem = self.editButton;
    self.navigationItem.rightBarButtonItem = self.doneButton;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MafiaGameSetupPlayersNumberOfSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == MafiaGameSetupPlayersListSection)
    {
        return [self.gameSetup.playerNames count];
    }
    else if (section == MafiaGameSetupPlayersAddSection)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MafiaGameSetupPlayersCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    if (indexPath.section == MafiaGameSetupPlayersListSection)
    {
        cell.imageView.image = [UIImage imageNamed:@"player.png"];
        cell.textLabel.text = [self.gameSetup.playerNames objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"add.png"];
        cell.textLabel.text = @"Add New Player";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == MafiaGameSetupPlayersListSection);
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == MafiaGameSetupPlayersListSection)
    {
        [self.gameSetup.playerNames removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == MafiaGameSetupPlayersListSection);
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.section == MafiaGameSetupPlayersListSection && toIndexPath.section == MafiaGameSetupPlayersListSection)
    {
        NSString *playerName = [[self.gameSetup.playerNames objectAtIndex:fromIndexPath.row] retain];
        [self.gameSetup.playerNames removeObjectAtIndex:fromIndexPath.row];
        [self.gameSetup.playerNames insertObject:playerName atIndex:toIndexPath.row];
        [playerName release];
        [self.tableView reloadData];
    }
}


#pragma mark - Table view delegate


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == MafiaGameSetupPlayersAddSection ? indexPath : nil);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == MafiaGameSetupPlayersAddSection && !self.tableView.editing)
    {
        UIViewController *addPlayerController = [MafiaGameSetupAddPlayerController controllerWithDelegate:self];
        [self.navigationController pushViewController:addPlayerController animated:YES];
    }
}


#pragma mark - MafiaGameSetupAddPlayerDelegate


- (void)addPlayerController:(MafiaGameSetupAddPlayerController *)controller didAddPlayer:(NSString *)name
{
    NSString *trimmedName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedName != nil && [trimmedName length] > 0)
    {
        [self.gameSetup.playerNames addObject:trimmedName];
    }
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
}


#pragma mark - Actions

- (void)editTapped:(id)sender
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (self.tableView.editing)
    {
        self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleDone;
        self.navigationItem.leftBarButtonItem.title = @"Done";
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleBordered;
        self.navigationItem.leftBarButtonItem.title = @"Edit";
        self.navigationItem.rightBarButtonItem = self.doneButton;
    }
}


- (void)doneTapped:(id)sender
{
    [self.delegate playersControllerDidComplete:self];
}


@end // MafiaGameSetupPlayersController

