//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaManagePlayersController.h"
#import "MafiaAddPlayerController.h"

#import "MafiaGameplay.h"


@interface MafiaManagePlayersController () <MafiaAddPlayerControllerDelegate>

@end


@implementation MafiaManagePlayersController


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
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
    return (section == 0 ? [self.gameSetup.playerNames count] : 0);
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.gameSetup.playerNames count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayerCell"];
        cell.imageView.image = [UIImage imageNamed:@"player.png"];
        cell.textLabel.text = self.gameSetup.playerNames[indexPath.row];
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
        [self.gameSetup.playerNames removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView
    moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
    if (fromIndexPath.section == toIndexPath.section) {
        NSString *playerName = self.gameSetup.playerNames[fromIndexPath.row];
        [self.gameSetup.playerNames removeObjectAtIndex:fromIndexPath.row];
        [self.gameSetup.playerNames insertObject:playerName atIndex:toIndexPath.row];
        [self.tableView reloadData];
    }
}


#pragma mark - UITableViewDelegate


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}


#pragma mark - MafiaAddPlayerControllerDelegate


- (void)addPlayerController:(UIViewController *)controller
       didAddPlayerWithName:(NSString *)name
                avatarImage:(UIImage *)avatarImage {
    if (name != nil) {
        [self.gameSetup.playerNames addObject:name];
    }
    // TODO: save player avatar image.
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddPlayer"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        MafiaAddPlayerController *addPlayerController = navigationController.viewControllers[0];
        addPlayerController.delegate = self;
    }
}


#pragma mark - Actions


- (void)addBarButtonItemTapped:(id)sender {
    [self performSegueWithIdentifier:@"AddPlayer" sender:sender];
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
