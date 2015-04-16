//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAssignRolesController.h"
#import "MafiaAutonomicGameController.h"
#import "MafiaGameController.h"
#import "MafiaStoryboards.h"

#import "MafiaGameplay.h"


static NSString *const kSegueStartJudgeDrivenGame = @"StartJudgeDrivenGame";

static NSString *const kTwoPlayersCellID = @"TwoPlayersCell";

@implementation MafiaTwoPlayersCell


- (void)refreshWithPlayer:(MafiaPlayer *)player1 andPlayer:(MafiaPlayer *)player2 {
    self.player1 = player1;
    self.player2 = player2;
    self.isPlayer1Revealed = NO;
    self.isPlayer2Revealed = NO;
    [self mafia_refreshUI];
}


- (IBAction)player1ButtonTapped:(id)sender {
    self.isPlayer1Revealed = !self.isPlayer1Revealed;
    [self mafia_refreshUI];
}


- (IBAction)player2ButtonTapped:(id)sender {
    self.isPlayer2Revealed = !self.isPlayer2Revealed;
    [self mafia_refreshUI];
}


- (void)mafia_refreshUI {
    [self mafia_refreshButton:self.player1Button
                    imageView:self.player1ImageView
                        label:self.player1Label
                    forPlayer:self.player1
                     revealed:self.isPlayer1Revealed];
    [self mafia_refreshButton:self.player2Button
                    imageView:self.player2ImageView
                        label:self.player2Label
                    forPlayer:self.player2
                     revealed:self.isPlayer2Revealed];
}


- (void)mafia_refreshButton:(UIButton *)button
                  imageView:(UIImageView *)imageView
                      label:(UILabel *)label
                  forPlayer:(MafiaPlayer *)player
                   revealed:(BOOL)isRevealed {
    if (player != nil) {
        button.enabled = YES;
        button.hidden = NO;
        imageView.hidden = NO;
        label.hidden = NO;
        if (isRevealed) {
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"role_%@.png", player.role.name]];
            label.text = player.role.displayName;
        } else {
            imageView.image = [UIImage imageNamed:@"role_unrevealed.png"];  // TODO: use player photo
            label.text = player.displayName;
        }
    } else {
        button.enabled = NO;
        button.hidden = YES;
        imageView.hidden = YES;
        label.hidden = YES;
    }
}


@end


@implementation MafiaAssignRolesController


#pragma mark - Public Methods


- (void)assignRolesRandomlyWithGameSetup:(MafiaGameSetup *)gameSetup {
    self.game = [[MafiaGame alloc] initWithGameSetup:gameSetup];
    [self.game assignRolesRandomly];
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // For N players, we need to have ceil(N / 2) cells, each cell holds 2 players.
    // Best way to calculate that: http://stackoverflow.com/questions/4926440/
    if (section == 0) {
        return ([self.game.playerList count] + 1) / 2;
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MafiaTwoPlayersCell *cell = [tableView dequeueReusableCellWithIdentifier:kTwoPlayersCellID forIndexPath:indexPath];
    NSUInteger playerIndex = indexPath.row * 2;
    MafiaPlayer *player1 = nil;
    if (playerIndex < [self.game.playerList count]) {
        player1 = [self.game.playerList playerAtIndex:playerIndex];
    }
    MafiaPlayer *player2 = nil;
    if (playerIndex + 1 < [self.game.playerList count]) {
        player2 = [self.game.playerList playerAtIndex:(playerIndex + 1)];
    }
    [cell refreshWithPlayer:player1 andPlayer:player2];
    return cell;
}


#pragma mark - Actions


- (IBAction)startButtonTapped:(id)sender {
    if ([self.game isReadyToStart]) {
        if (!self.game.gameSetup.isAutonomic) {
            // Judge-driven game.
            // TODO: move this to a separate storyboard.
            [self performSegueWithIdentifier:kSegueStartJudgeDrivenGame sender:self];
        } else {
            // Autonomic game.
            MafiaAutonomicGameController *controller = [MafiaStoryboards instantiateAutonomicGameController];
            [controller startGame:self.game];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // TODO: move this to a separate storyboard.
    if ([segue.identifier isEqualToString:kSegueStartJudgeDrivenGame]) {
        MafiaGameController *controller = segue.destinationViewController;
        [controller startGame:self.game];
    }
}


@end
