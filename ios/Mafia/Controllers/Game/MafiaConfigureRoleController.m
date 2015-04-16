//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaConfigureRoleController.h"

#import "MafiaGameplay.h"


static const NSInteger kMinNumberOfActors = 1;  // Minimal 1 killer or detective.
static const NSInteger kMaxNumberOfActors = 4;  // Maximal 4 killers or detectives.

static NSString *const kCellID = @"Cell";


@implementation MafiaConfigureRoleController


#pragma mark - Properties


@dynamic numberOfActors;

- (NSInteger)numberOfActors {
    return [self.gameSetup numberOfActorsForRole:self.role];
}

- (void)setNumberOfActors:(NSInteger)numberOfActors {
    NSAssert(numberOfActors >= kMinNumberOfActors && numberOfActors <= kMaxNumberOfActors,
             @"Number of actors out of range [%@, %@].", @(kMinNumberOfActors), @(kMaxNumberOfActors));
    [self.gameSetup setNumberOfActors:numberOfActors forRole:self.role];
}


#pragma mark - Lifecycle


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.role.displayName;
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (kMaxNumberOfActors - kMinNumberOfActors + 1);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"role_%@.png", self.role.name]];
    NSInteger numberOfActorsForCell = kMinNumberOfActors + indexPath.row;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ x %@", self.role.displayName, @(numberOfActorsForCell)];
    if (numberOfActorsForCell == self.numberOfActors) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowForNumberOfActors = self.numberOfActors - kMinNumberOfActors;
    NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:rowForNumberOfActors inSection:0];
    if (![previousIndexPath isEqual:indexPath]) {
        // Update number of actors.
        self.numberOfActors = kMinNumberOfActors + indexPath.row;
        // Check the currently selected cell.
        UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
        // Uncheck the previously selected cell.
        UITableViewCell *previousCell = [tableView cellForRowAtIndexPath:previousIndexPath];
        previousCell.accessoryType = UITableViewCellAccessoryNone;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
