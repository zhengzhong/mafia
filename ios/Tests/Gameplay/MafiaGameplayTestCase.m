//
//  Created by ZHENG Zhong on 2012-12-06.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameplayTestCase.h"

#import "MafiaGameplay.h"


@implementation MafiaGameplayTestCase


@synthesize playerList = _playerList;
@synthesize assassin = _assassin;
@synthesize killer1 = _killer1;
@synthesize killer2 = _killer2;
@synthesize detective1 = _detective1;
@synthesize detective2 = _detective2;
@synthesize guardian = _guardian;
@synthesize doctor = _doctor;
@synthesize traitor = _traitor;
@synthesize undercover = _undercover;


- (void)setUp
{
    [super setUp];
    NSArray *playerNames = @[@"Assassin", @"Guardian", @"Killer 1", @"Killer 2",
                             @"Detective 1", @"Detective 2", @"Doctor", @"Traitor", @"Undercover",
                             @"Civilian 1", @"Civilian 2", @"Civilian 3", @"Civilian 4"];
    self.playerList = [[MafiaPlayerList alloc] initWithPlayerNames:playerNames isTwoHanded:NO];
    self.assassin = [self.playerList playerNamed:@"Assassin"];
    self.killer1 = [self.playerList playerNamed:@"Killer 1"];
    self.killer2 = [self.playerList playerNamed:@"Killer 2"];
    self.detective1 = [self.playerList playerNamed:@"Detective 1"];
    self.detective1 = [self.playerList playerNamed:@"Detective 2"];
    self.guardian = [self.playerList playerNamed:@"Guardian"];
    self.doctor = [self.playerList playerNamed:@"Doctor"];
    self.traitor = [self.playerList playerNamed:@"Traitor"];
    self.undercover = [self.playerList playerNamed:@"Undercover"];
}


- (void)resetPlayerListAndAssignRoles
{
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
    for (MafiaPlayer *player in self.playerList)
    {
        if ([player isUnrevealed])
        {
            player.role = [MafiaRole civilian];
        }
    }
}


@end // MafiaGameplayTestCase

