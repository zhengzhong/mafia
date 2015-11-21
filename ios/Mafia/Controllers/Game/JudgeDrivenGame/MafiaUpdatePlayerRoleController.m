//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaUpdatePlayerRoleController.h"

#import "MafiaAssets.h"
#import "MafiaGameplay.h"

#import "UINavigationItem+MafiaBackTitle.h"


static NSString *const kRoleCellID = @"RoleCell";


@implementation MafiaUpdatePlayerRoleController


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem mafia_clearBackTitle];
    self.navigationItem.hidesBackButton = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = NSLocalizedString(@"Select a Role", nil);
}


#pragma mark - Public Methods


- (void)setRole:(MafiaRole *)role {
    self.originalRole = role;
    self.selectedRole = role;
    self.roles = [MafiaRole roles];
}


#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.roles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRoleCellID forIndexPath:indexPath];
    MafiaRole *role = self.roles[indexPath.row];
    cell.imageView.image = [MafiaAssets smallImageOfRole:role];
    cell.textLabel.text = role.displayName;
    cell.accessoryType = ([role isEqualToRole:self.selectedRole] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    return cell;
}


#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Uncheck previously selected role cell.
    NSUInteger previousIndex = [self.roles indexOfObject:self.selectedRole];
    if (previousIndex != NSNotFound) {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:previousIndex inSection:0];
        UITableViewCell *previousCell = [tableView cellForRowAtIndexPath:previousIndexPath];
        previousCell.accessoryType = UITableViewCellAccessoryNone;
    }
    // Update selected role, and check currently selected role cell.
    self.selectedRole = self.roles[indexPath.row];
    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    // Unselect row.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Actions


- (IBAction)cancelButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)doneButtonTapped:(id)sender {
    [self.delegate updatePlayerRoleController:self didUpdateRole:self.selectedRole];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
