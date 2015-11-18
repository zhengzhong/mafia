//
//  Created by ZHENG Zhong on 2015-04-22.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaLoadGameSetupController.h"

#import "MafiaGameplay.h"


static NSString *const kGameSetupNameCellID = @"GameSetupName";


@interface MafiaLoadGameSetupController ()

@property (strong, nonatomic) NSMutableArray *gameSetupNames;

@property (strong, nonatomic) UIBarButtonItem *cancelButton;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *doneEditingButton;

- (void)cancelButtonTapped:(id)sender;

- (void)editButtonTapped:(id)sender;

- (void)doneEditingButtonTapped:(id)sender;

@end


@implementation MafiaLoadGameSetupController


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameSetupNames = [[MafiaGameSetup namesOfSavedGameSetups] mutableCopy];
    // Configure navigation bar buttons manually.
    self.cancelButton = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                             target:self
                             action:@selector(cancelButtonTapped:)];
    self.editButton = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                             target:self
                             action:@selector(editButtonTapped:)];
    self.doneEditingButton = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self
                             action:@selector(doneEditingButtonTapped:)];
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    self.navigationItem.rightBarButtonItem = self.editButton;
}


#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.gameSetupNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.gameSetupNames count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGameSetupNameCellID forIndexPath:indexPath];
        cell.textLabel.text = self.gameSetupNames[indexPath.row];
        return cell;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row < [self.gameSetupNames count]) {
            NSString *gameSetupName = self.gameSetupNames[indexPath.row];
            [MafiaGameSetup removeGameSetupWithName:gameSetupName];
            [self.gameSetupNames removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
        }
    }
}


#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.gameSetupNames count]) {
        NSString *gameSetupName = self.gameSetupNames[indexPath.row];
        MafiaGameSetup *gameSetup = [MafiaGameSetup loadWithName:gameSetupName];
        [self.delegate loadGameSetupController:self didLoadGameSetup:gameSetup];
    }
}


#pragma mark - Navigation Bar Button Actions


- (void)cancelButtonTapped:(id)sender {
    [self.delegate loadGameSetupControllerDidCancel:self];
}


- (void)editButtonTapped:(id)sender {
    if (!self.tableView.editing) {
        [self.tableView setEditing:YES animated:YES];
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        [self.navigationItem setRightBarButtonItem:self.doneEditingButton animated:YES];
    }
}


- (void)doneEditingButtonTapped:(id)sender {
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
        [self.navigationItem setLeftBarButtonItem:self.cancelButton animated:YES];
        [self.navigationItem setRightBarButtonItem:self.editButton animated:YES];
    }
}


@end
