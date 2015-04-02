//
//  Created by ZHENG Zhong on 2012-12-07.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameplayTestCase.h"
#import "MafiaGameplay.h"


@interface MafiaVoteAndLynchActionTests : MafiaGameplayTestCase

@property (strong, nonatomic) MafiaSettleTagsAction *settleTagsAction;
@property (strong, nonatomic) MafiaVoteAndLynchAction *voteAndLynchAction;

@end


@implementation MafiaVoteAndLynchActionTests


- (void)setUp {
    [super setUp];
    self.settleTagsAction = [MafiaSettleTagsAction actionWithPlayerList:self.playerList];
    self.voteAndLynchAction = [MafiaVoteAndLynchAction actionWithPlayerList:self.playerList];
}


- (void)testPlayerIsLynchedWhenVoted {
    for (MafiaPlayer *player in self.playerList) {
        [self resetPlayerListAndAssignRoles];
        // When
        player.isVoted = YES;
        [self.voteAndLynchAction settleVoteAndLynch];
        // Then
        XCTAssertTrue(player.isDead, @"Player should be lynched when voted.");
    }
}


- (void)testPlayerIsNotLynchedWhenGuardedAndVoted {
    for (MafiaPlayer *player in self.playerList) {
        [self resetPlayerListAndAssignRoles];
        // When: guarded during the night.
        [player selectByRole:[MafiaRole guardian]];
        [self.settleTagsAction settleTags];
        // Then
        XCTAssertTrue(player.isJustGuarded, @"Player should be just guarded when guarded.");
        // When: vote during the day.
        player.isVoted = YES;
        // Then
        XCTAssertTrue(player.isJustGuarded, @"Player should be just guarded when guarded.");
        XCTAssertFalse(player.isDead, @"Player should not be lynched when guarded and voted.");
    }
}


@end  // MafiaVoteAndLynchActionTests
