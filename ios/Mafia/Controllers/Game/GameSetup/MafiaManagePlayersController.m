//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaManagePlayersController.h"
#import "MafiaAddPersonController.h"

#import "MafiaAssets.h"
#import "MafiaGameplay.h"
#import "UINavigationItem+MafiaBackTitle.h"
#import "UIView+MafiaAdditions.h"


static NSString *const kPlayerCellID = @"PlayerCell";


@implementation MafiaManagePlayersPlayerCell

- (void)setupWithPerson:(MafiaPerson *)person {
    if (person.avatarImage != nil) {
        self.avatarImageView.image = person.avatarImage;
    } else {
        self.avatarImageView.image = [MafiaAssets imageOfAvatar:MafiaAvatarDefault];
    }
    [self.avatarImageView mafia_makeRoundCornersWithBorder:NO];
    self.nameLabel.text = person.name;
}

@end


@interface MafiaManagePlayersController () <MafiaAddPersonControllerDelegate>

@end


@implementation MafiaManagePlayersController


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem mafia_clearBackTitle];

    // We cannot add multiple buttons to the top bar via storyboard, so we do this manually.
    self.addBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                             target:self
                             action:@selector(addBarButtonItemTapped:)];
    self.editBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                             target:self
                             action:@selector(editBarButtonItemTapped:)];
    self.doneEditingBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self
                             action:@selector(doneEditingBarButtonItemTapped:)];
    self.navigationItem.rightBarButtonItems = @[self.addBarButtonItem, self.editBarButtonItem];
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0 ? [self.gameSetup.persons count] : 0);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.gameSetup.persons count]) {
        MafiaPerson *person = self.gameSetup.persons[indexPath.row];
        MafiaManagePlayersPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlayerCellID forIndexPath:indexPath];
        [cell setupWithPerson:person];
        return cell;
    }
    return nil;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row < [self.gameSetup.persons count]) {
            [self.gameSetup.persons removeObjectAtIndex:indexPath.row];
        }
        [self.tableView reloadData];
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView
    moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
    if (fromIndexPath.section == toIndexPath.section && fromIndexPath.row != toIndexPath.row) {
        MafiaPerson *person = self.gameSetup.persons[fromIndexPath.row];
        [self.gameSetup.persons removeObjectAtIndex:fromIndexPath.row];
        [self.gameSetup.persons insertObject:person atIndex:toIndexPath.row];
        [self.tableView reloadData];
    }
}


#pragma mark - UITableViewDelegate


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}


#pragma mark - MafiaAddPersonControllerDelegate


- (void)addPersonController:(UIViewController *)controller didAddPersonOrNil:(MafiaPerson *)person {
    if (person != nil) {
        [self.gameSetup.persons addObject:person];
    }
    // TODO: save person (name and avatar image).
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddPerson"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        MafiaAddPersonController *addPersonController = navigationController.viewControllers[0];
        addPersonController.delegate = self;
    }
}


#pragma mark - Actions


- (void)addBarButtonItemTapped:(id)sender {
    [self performSegueWithIdentifier:@"AddPerson" sender:sender];
}


- (void)editBarButtonItemTapped:(id)sender {
    if (!self.tableView.editing) {
        [self.tableView setEditing:YES animated:YES];
        [self.navigationItem setRightBarButtonItems:@[self.doneEditingBarButtonItem] animated:YES];
    }
}


- (void)doneEditingBarButtonItemTapped:(id)sender {
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
        [self.navigationItem setRightBarButtonItems:@[self.addBarButtonItem, self.editBarButtonItem] animated:YES];
    }
}


@end
