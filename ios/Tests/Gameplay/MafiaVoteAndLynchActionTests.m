//
//  Created by ZHENG Zhong on 2012-12-07.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameplayTestCase.h"
#import "MafiaGameplay.h"


@interface MafiaVoteAndLynchActionTests : MafiaGameplayTestCase

@property (retain, nonatomic) MafiaSettleTagsAction *settleTagsAction;
@property (retain, nonatomic) MafiaVoteAndLynchAction *voteAndLynchAction;

@end // MafiaVoteAndLynchActionTests


@implementation MafiaVoteAndLynchActionTests


@synthesize settleTagsAction = _settleTagsAction;
@synthesize voteAndLynchAction = _voteAndLynchAction;


- (void)setUp
{
    [super setUp];
    self.settleTagsAction = [MafiaSettleTagsAction actionWithPlayerList:self.playerList];
    self.voteAndLynchAction = [MafiaVoteAndLynchAction actionWithPlayerList:self.playerList];
}


- (void)tearDown
{
    [super tearDown];
}


- (void)testPlayerIsLynchedWhenVoted
{
    for (MafiaPlayer *player in self.playerList)
    {
        [self resetPlayerListAndAssignRoles];
        player.isVoted = YES;
        [self.voteAndLynchAction settleVoteAndLynch];
        STAssertTrue(player.isDead, @"Player should be lynched when voted.");
    }
}


- (void)testPlayerIsNotLynchedWhenGuardedAndVoted
{
    for (MafiaPlayer *player in self.playerList)
    {
        [self resetPlayerListAndAssignRoles];
        // Guarded during the night.
        [player selectByRole:[MafiaRole guardian]];
        [self.settleTagsAction settleTags];
        STAssertTrue(player.isJustGuarded, @"Player should be just guarded when guarded.");
        // Vote during the day.
        player.isVoted = YES;
        STAssertTrue(player.isJustGuarded, @"Player should be just guarded when guarded.");
        STAssertFalse(player.isDead, @"Player should not be lynched when guarded and voted.");
    }
}


@end //MafiaVoteAndLynchActionTests

