//
//  Created by ZHENG Zhong on 2012-12-06.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameplayTestCase.h"
#import "MafiaGameplay.h"


@interface MafiaSettleTagsActionTests : MafiaGameplayTestCase

@property (strong, nonatomic) MafiaSettleTagsAction *settleTagsAction;

@end


@implementation MafiaSettleTagsActionTests


- (void)setUp {
    [super setUp];
    self.settleTagsAction = [MafiaSettleTagsAction actionWithPlayerList:self.playerList];
}


- (void)testPlayerIsKilledWhenShot {
    for (MafiaPlayer *player in self.playerList) {
        [self resetPlayerListAndAssignRoles];
        if (![player.role isEqualToRole:[MafiaRole assassin]]) {
            // When
            [player selectByRole:[MafiaRole killer]];
            [self.settleTagsAction settleTags];
            // Then
            XCTAssertTrue(player.isDead, @"Player should be dead when shot.");
        }
    }
}


- (void)testAssassinIsNotKilledWhenShot {
    [self resetPlayerListAndAssignRoles];
    // When
    [self.assassin selectByRole:[MafiaRole killer]];
    [self.settleTagsAction settleTags];
    // Then
    XCTAssertFalse(self.assassin.isDead, @"Assassin should not be killed when shot.");
}


- (void)testPlayerIsNotKilledOrMisdiagnosedWhenShotAndHealt {
    for (MafiaPlayer *player in self.playerList) {
        [self resetPlayerListAndAssignRoles];
        if (![player.role isEqualToRole:[MafiaRole assassin]]) {
            // When
            [player selectByRole:[MafiaRole killer]];
            [player selectByRole:[MafiaRole doctor]];
            [self.settleTagsAction settleTags];
            // Then
            XCTAssertFalse(player.isDead, @"Player should not be killed when shot and healt.");
            XCTAssertFalse(player.isMisdiagnosed, @"Player should not be misdiagnosed when shot and healt.");
        }
    }
}


- (void)testAssassinIsNotKilledButMisdiagnosedWhenShotAndHealt {
    [self resetPlayerListAndAssignRoles];
    // When
    [self.assassin selectByRole:[MafiaRole killer]];
    [self.assassin selectByRole:[MafiaRole doctor]];
    [self.settleTagsAction settleTags];
    // Then
    XCTAssertTrue(self.assassin.isMisdiagnosed, @"Assassin should be misdiagnosed when shot and healt.");
    XCTAssertFalse(self.assassin.isDead, @"Assassin should not be killed when shot.");
}


- (void)testPlayerIsMisdiagnosedWhenHealtAndNotShot {
    for (MafiaPlayer *player in self.playerList) {
        [self resetPlayerListAndAssignRoles];
        // When
        [player selectByRole:[MafiaRole doctor]];
        [self.settleTagsAction settleTags];
        // Then
        XCTAssertFalse(player.isDead, @"Player should not be killed when healt and not shot.");
        XCTAssertTrue(player.isMisdiagnosed, @"Player should be misdiagnosed when healt and not shot.");
    }
}


- (void)testPlayerIsKilledWhenMisdiagnosedTwice {
    for (MafiaPlayer *player in self.playerList) {
        [self resetPlayerListAndAssignRoles];
        // When: misdiagnosed for the first time.
        [player selectByRole:[MafiaRole doctor]];
        [self.settleTagsAction settleTags];
        // Then
        XCTAssertTrue(player.isMisdiagnosed, @"Player should be misdiagnosed when healt and not shot.");
        XCTAssertFalse(player.isDead, @"Player should not be killed when healt and not shot.");
        // When: misdiagnosed for the second time.
        [player selectByRole:[MafiaRole doctor]];
        [self.settleTagsAction settleTags];
        // Then
        XCTAssertTrue(player.isMisdiagnosed, @"Player should be misdiagnosed when healt and not shot.");
        XCTAssertTrue(player.isDead, @"Player should be killed when misdiagnosed twice.");
    }
}


- (void)testPlayerIsNotKilledWhenShotAndGuarded {
    for (MafiaPlayer *player in self.playerList) {
        [self resetPlayerListAndAssignRoles];
        if (![player.role isEqualToRole:[MafiaRole guardian]]) {
            // When
            [player selectByRole:[MafiaRole killer]];
            [player selectByRole:[MafiaRole guardian]];
            [self.settleTagsAction settleTags];
            // Then
            XCTAssertFalse(player.isDead, @"Player should not be killed when shot and guarded.");
            XCTAssertTrue(player.isJustGuarded, @"Player should be just guarded when shot and guarded.");
        }
    }
}


- (void)testGuardianIsKilledWhenGuardedAndShot {
    [self resetPlayerListAndAssignRoles];
    // When
    [self.guardian selectByRole:[MafiaRole guardian]];
    [self.guardian selectByRole:[MafiaRole killer]];
    [self.settleTagsAction settleTags];
    // Then
    XCTAssertTrue(self.guardian.isDead, @"Guardian should be killed when guarded and shot.");
}


- (void)testPlayerIsNotMisdiagnosedWhenGuardedAndHealt {
    for (MafiaPlayer *player in self.playerList) {
        [self resetPlayerListAndAssignRoles];
        // When
        [player selectByRole:[MafiaRole guardian]];
        [player selectByRole:[MafiaRole doctor]];
        [self.settleTagsAction settleTags];
        // Then
        XCTAssertFalse(player.isDead, @"Player should not be killed when guarded and healt.");
        XCTAssertFalse(player.isMisdiagnosed, @"Player should not be misdiagnosed when guarded and healt.");
        XCTAssertTrue(player.isJustGuarded, @"Player should be just guarded when guarded and healt.");
    }
}


- (void)testPlayerIsNotMisdiagnosedWhenHealtAndDoctorWasGuarded {
    for (MafiaPlayer *player in self.playerList) {
        [self resetPlayerListAndAssignRoles];
        // When
        [self.doctor selectByRole:[MafiaRole guardian]];
        [player selectByRole:[MafiaRole doctor]];
        [self.settleTagsAction settleTags];
        // Then
        XCTAssertFalse(player.isMisdiagnosed, @"Player should not be misdiagnosed when healt and doctor was guarded.");
    }
}


- (void)testPlayerIsNotKilledWhenShotAndKillerWasGuarded {
    for (MafiaPlayer *player in self.playerList) {
        [self resetPlayerListAndAssignRoles];
        if (![player.role isEqualToRole:[MafiaRole guardian]]) {
            // When
            [self.killer1 selectByRole:[MafiaRole guardian]];
            [player selectByRole:[MafiaRole killer]];
            [self.settleTagsAction settleTags];
            // Then
            XCTAssertFalse(player.isDead, @"Player should not be killed when shot and killer was guarded.");
        }
    }
}


- (void)testGuardianAndKillerAreKilledWhenGuardianWasShotAndKillerWasGuarded {
    [self resetPlayerListAndAssignRoles];
    // When
    [self.killer1 selectByRole:[MafiaRole guardian]];
    [self.guardian selectByRole:[MafiaRole killer]];
    [self.settleTagsAction settleTags];
    // Then
    XCTAssertTrue(self.guardian.isDead, @"Guardian should be killed when shot and killer was guarded.");
    XCTAssertTrue(self.killer1.isDead, @"Killer1 should be killed when guarded and guardian was shot.");
    XCTAssertFalse(self.killer2.isDead, @"Killer2 should not be killed when killer1 was guarded and guardian was shot.");
}


- (void)testGuardianAndPlayerAreKilledWhenPlayerWasGuardedAndGuardianWasShot {
    for (MafiaPlayer *player in self.playerList) {
        [self resetPlayerListAndAssignRoles];
        // When
        [player selectByRole:[MafiaRole guardian]];
        [self.guardian selectByRole:[MafiaRole killer]];
        [self.settleTagsAction settleTags];
        // Then
        XCTAssertTrue(self.guardian.isDead, @"Guardian should be killed when shot.");
        XCTAssertTrue(player.isDead, @"Player should be killed when guarded and guardian was shot.");
    }
}


- (void)testPlayerIsNotKilledOrMisdiagnosedWhenShotAndHealtAndGuarded {
    for (MafiaPlayer *player in self.playerList) {
        [self resetPlayerListAndAssignRoles];
        if (![player.role isEqualToRole:[MafiaRole guardian]]) {
            // When
            [player selectByRole:[MafiaRole guardian]];
            [player selectByRole:[MafiaRole killer]];
            [player selectByRole:[MafiaRole doctor]];
            [self.settleTagsAction settleTags];
            // Then
            XCTAssertFalse(player.isDead, @"Player should not be killed when shot and healt and guarded.");
            XCTAssertFalse(player.isMisdiagnosed, @"Player should not be misdiagnosed when shot and healt and guarded.");
        }
    }
}


- (void)testGuardianIsKilledAndNotMisdiagnosedWhenShotAndHealtAndGuarded {
    [self resetPlayerListAndAssignRoles];
    // When
    [self.guardian selectByRole:[MafiaRole guardian]];
    [self.guardian selectByRole:[MafiaRole killer]];
    [self.guardian selectByRole:[MafiaRole doctor]];
    [self.settleTagsAction settleTags];
    // Then
    XCTAssertTrue(self.guardian.isDead, @"Guardian should be killed when shot and healt and guarded.");
    XCTAssertFalse(self.guardian.isMisdiagnosed, @"Guardian should not be misdiagnosed when shot and healt and guarded.");
}


- (void)testPlayerIsUnguardableWhenGuardedTwiceContinuously {
    for (MafiaPlayer *player in self.playerList) {
        [self resetPlayerListAndAssignRoles];
        // When: guarded for the first time.
        [player selectByRole:[MafiaRole guardian]];
        [self.settleTagsAction settleTags];
        // Then
        XCTAssertTrue(player.isJustGuarded, @"Player should be just guarded when guarded.");
        XCTAssertFalse(player.isUnguardable, @"Player should not be unguardable when guarded for the first time.");
        // When: guarded for the second time.
        [player selectByRole:[MafiaRole guardian]];
        [self.settleTagsAction settleTags];
        // Then
        XCTAssertTrue(player.isJustGuarded, @"Player should be just guarded when guarded.");
        XCTAssertTrue(player.isUnguardable, @"Player should be unguardable when guarded twice continuously.");
    }
}


- (void)testPlayerIsNotUnguardableWhenGuardedTwiceButNotContinuously {
    for (MafiaPlayer *player in self.playerList) {
        [self resetPlayerListAndAssignRoles];
        // When: guarded for the first time.
        [player selectByRole:[MafiaRole guardian]];
        [self.settleTagsAction settleTags];
        // Then
        XCTAssertTrue(player.isJustGuarded, @"Player should be just guarded when guarded.");
        XCTAssertFalse(player.isUnguardable, @"Player should not be unguardable when guarded for the first time.");
        // When: not guarded this time.
        [self.settleTagsAction settleTags];
        // Then
        XCTAssertFalse(player.isJustGuarded, @"Player should not be just guarded when not guarded.");
        XCTAssertFalse(player.isUnguardable, @"Player should not be unguardable when not guarded.");
        // When: guarded for the second time, but not continuously.
        [player selectByRole:[MafiaRole guardian]];
        [self.settleTagsAction settleTags];
        // Then
        XCTAssertTrue(player.isJustGuarded, @"Player should be just guarded when guarded.");
        XCTAssertFalse(player.isUnguardable, @"Player should not be unguardable when guarded twice but not continuously.");
    }
}


- (void)testGuardianIsNotKilledOrMisdiagnosedWhenShotAndHealtAndKillerWasGuarded {
    [self resetPlayerListAndAssignRoles];
    // When
    [self.killer1 selectByRole:[MafiaRole guardian]];
    [self.guardian selectByRole:[MafiaRole killer]];
    [self.guardian selectByRole:[MafiaRole doctor]];
    [self.settleTagsAction settleTags];
    // Then
    XCTAssertFalse(self.guardian.isDead, @"Guardian should not be killed when shot and healt and killer was guarded.");
    XCTAssertFalse(self.guardian.isMisdiagnosed, @"Guardian should not be misdiagnosed when shot and healt and killer was guarded.");
    XCTAssertFalse(self.killer1.isDead, @"Killer1 should not be killed when guarded and guardian was shot and healt.");
}


@end  // MafiaSettleTagsActionTests
