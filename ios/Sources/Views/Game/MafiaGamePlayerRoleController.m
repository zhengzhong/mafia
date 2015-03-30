//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGamePlayerRoleController.h"

#import "../../Gameplay/MafiaGameplay.h"


@implementation MafiaGamePlayerRoleController


@synthesize originalRole = _originalRole;
@synthesize selectedRole = _selectedRole;
@synthesize roles = _roles;
@synthesize delegate = _delegate;


+ (id)controllerWithRole:(MafiaRole *)role delegate:(id<MafiaGamePlayerRoleControllerDelegate>)delegate
{
    return [[self alloc] initWithRole:role delegate:delegate];
}




- (id)initWithRole:(MafiaRole *)role delegate:(id<MafiaGamePlayerRoleControllerDelegate>)delegate
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        _originalRole = role;
        _selectedRole = role;
        _roles = [[MafiaRole roles] copy];
        _delegate = delegate;
        self.title = role.displayName;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                   target:self
                                   action:@selector(doneTapped:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                     target:self
                                     action:@selector(cancelTapped:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.roles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MafiaGamePlayerRoleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    MafiaRole *role = [self.roles objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"role_%@.png", role.name]];
    cell.textLabel.text = role.displayName;
    cell.accessoryType = (role == self.selectedRole ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    return cell;
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Uncheck previously selected role cell.
    NSUInteger previousIndex = [self.roles indexOfObject:self.selectedRole];
    if (previousIndex != NSNotFound)
    {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:previousIndex inSection:0];
        UITableViewCell *previousCell = [tableView cellForRowAtIndexPath:previousIndexPath];
        previousCell.accessoryType = UITableViewCellAccessoryNone;
    }
    // Check currently selected role cell.
    self.selectedRole = [self.roles objectAtIndex:indexPath.row];
    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    // Unselect row.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UIBarButtonItem actions


- (void)doneTapped:(id)sender
{
    [self.delegate playerRoleController:self didCompleteWithRole:self.selectedRole];
}


- (void)cancelTapped:(id)sender
{
    [self.delegate playerRoleController:self didCompleteWithRole:self.originalRole];
}


@end // MafiaGamePlayerRoleController

