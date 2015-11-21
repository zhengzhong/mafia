//
//  Created by ZHENG Zhong on 2012-12-06.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameplayTestCase.h"

#import "MafiaGameplay.h"


@implementation MafiaGameplayTestCase


- (void)setUp {
    [super setUp];
    NSArray *persons = @[
        [MafiaPerson personWithName:@"Killer_1" avatarImage:nil],
        [MafiaPerson personWithName:@"Killer_2" avatarImage:nil],
        [MafiaPerson personWithName:@"Detective_1" avatarImage:nil],
        [MafiaPerson personWithName:@"Detective_2" avatarImage:nil],
        [MafiaPerson personWithName:@"Assassin" avatarImage:nil],
        [MafiaPerson personWithName:@"Guardian" avatarImage:nil],
        [MafiaPerson personWithName:@"Doctor" avatarImage:nil],
        [MafiaPerson personWithName:@"Traitor" avatarImage:nil],
        [MafiaPerson personWithName:@"Undercover" avatarImage:nil],
        [MafiaPerson personWithName:@"Civilian_1" avatarImage:nil],
        [MafiaPerson personWithName:@"Civilian_2" avatarImage:nil],
        [MafiaPerson personWithName:@"Civilian_3" avatarImage:nil],
        [MafiaPerson personWithName:@"Civilian_4" avatarImage:nil],
    ];
    self.playerList = [[MafiaPlayerList alloc] initWithPersons:persons isTwoHanded:NO];
    self.assassin = [self.playerList playerWithName:@"Assassin" handSide:MafiaHandSideBoth];
    self.killer1 = [self.playerList playerWithName:@"Killer_1" handSide:MafiaHandSideBoth];
    self.killer2 = [self.playerList playerWithName:@"Killer_2" handSide:MafiaHandSideBoth];
    self.detective1 = [self.playerList playerWithName:@"Detective_1" handSide:MafiaHandSideBoth];
    self.detective1 = [self.playerList playerWithName:@"Detective_2" handSide:MafiaHandSideBoth];
    self.guardian = [self.playerList playerWithName:@"Guardian" handSide:MafiaHandSideBoth];
    self.doctor = [self.playerList playerWithName:@"Doctor" handSide:MafiaHandSideBoth];
    self.traitor = [self.playerList playerWithName:@"Traitor" handSide:MafiaHandSideBoth];
    self.undercover = [self.playerList playerWithName:@"Undercover" handSide:MafiaHandSideBoth];
}


- (void)resetPlayerListAndAssignRoles {
    [self.playerList reset];
    self.assassin.role = [MafiaRole assassin];
    self.killer1.role = [MafiaRole killer];
    self.killer2.role = [MafiaRole killer];
    self.detective1.role = [MafiaRole detective];
    self.detective2.role = [MafiaRole detective];
    self.guardian.role = [MafiaRole guardian];
    self.doctor.role = [MafiaRole doctor];
    self.traitor.role = [MafiaRole traitor];
    self.undercover.role = [MafiaRole undercover];
    for (MafiaPlayer *player in self.playerList) {
        if (player.role == nil) {
            player.role = [MafiaRole civilian];
        }
    }
}


@end
