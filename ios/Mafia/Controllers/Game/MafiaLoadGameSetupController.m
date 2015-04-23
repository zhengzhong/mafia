//
//  Created by ZHENG Zhong on 2015-04-22.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaLoadGameSetupController.h"

#import "MafiaGameplay.h"


static NSString *const kGameSetupNameCellID = @"GameSetupName";


@interface MafiaLoadGameSetupController ()

@property (strong, nonatomic) NSMutableArray *gameSetupNames;

@end


@implementation MafiaLoadGameSetupController


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameSetupNames = [[MafiaGameSetup namesOfSavedGameSetups] mutableCopy];
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
        MafiaGameSetup *gameSetup = [MafiaGameSetup loadGameSetupWithName:gameSetupName];
        [self.delegate loadGameSetupController:self didLoadGameSetup:gameSetup];
    }
}


@end
