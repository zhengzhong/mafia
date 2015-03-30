//
//  Created by ZHENG Zhong on 2012-12-06.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameplayTestCase.h"
#import "MafiaGameplay.h"


@interface MafiaSettleTagsActionTests : MafiaGameplayTestCase

@property (strong, nonatomic) MafiaSettleTagsAction *settleTagsAction;

@end // MafiaSettleTagsActionTests


@implementation MafiaSettleTagsActionTests


@synthesize settleTagsAction = _settleTagsAction;


- (void)setUp
{
    [super setUp];
    self.settleTagsAction = [MafiaSettleTagsAction actionWithPlayerList:self.playerList];
}


- (void)tearDown
{
    [super tearDown];
}


- (void)testPlayerIsKilledWhenShot
{
    for (MafiaPlayer *player in self.playerList)
    {
        [self resetPlayerListAndAssignRoles];
        if (player.role != [MafiaRole assassin])
        {
            [player selectByRole:[MafiaRole killer]];
            [self.settleTagsAction settleTags];
            STAssertTrue(player.isDead, @"Player should be dead when shot.");
        }
    }
}


- (void)testAssassinIsNotKilledWhenShot
{
    [self resetPlayerListAndAssignRoles];
    [self.assassin selectByRole:[MafiaRole killer]];
    [self.settleTagsAction settleTags];
    STAssertFalse(self.assassin.isDead, @"Assassin should not be killed when shot.");
}


- (void)testPlayerIsNotKilledOrMisdiagnosedWhenShotAndHealt
{
    for (MafiaPlayer *player in self.playerList)
    {
        [self resetPlayerListAndAssignRoles];
        if (player.role != [MafiaRole assassin])
        {
            [player selectByRole:[MafiaRole killer]];
            [player selectByRole:[MafiaRole doctor]];
            [self.settleTagsAction settleTags];
            STAssertFalse(player.isDead, @"Player should not be killed when shot and healt.");
            STAssertFalse(player.isMisdiagnosed, @"Player should not be misdiagnosed when shot and healt.");
        }
    }
}


- (void)testAssassinIsNotKilledButMisdiagnosedWhenShotAndHealt
{
    [self resetPlayerListAndAssignRoles];
    [self.assassin selectByRole:[MafiaRole killer]];
    [self.assassin selectByRole:[MafiaRole doctor]];
    [self.settleTagsAction settleTags];
    STAssertTrue(self.assassin.isMisdiagnosed, @"Assassin should be misdiagnosed when shot and healt.");
    STAssertFalse(self.assassin.isDead, @"Assassin should not be killed when shot.");
}


- (void)testPlayerIsMisdiagnosedWhenHealtAndNotShot
{
    for (MafiaPlayer *player in self.playerList)
    {
        [self resetPlayerListAndAssignRoles];
        [player selectByRole:[MafiaRole doctor]];
        [self.settleTagsAction settleTags];
        STAssertFalse(player.isDead, @"Player should not be killed when healt and not shot.");
        STAssertTrue(player.isMisdiagnosed, @"Player should be misdiagnosed when healt and not shot.");
    }
}


- (void)testPlayerIsKilledWhenMisdiagnosedTwice
{
    for (MafiaPlayer *player in self.playerList)
    {
        [self resetPlayerListAndAssignRoles];
        // Misdiagnosed for the first time.
        [player selectByRole:[MafiaRole doctor]];
        [self.settleTagsAction settleTags];
        STAssertTrue(player.isMisdiagnosed, @"Player should be misdiagnosed when healt and not shot.");
        STAssertFalse(player.isDead, @"Player should not be killed when healt and not shot.");
        // Misdiagnosed for the second time.
        [player selectByRole:[MafiaRole doctor]];
        [self.settleTagsAction settleTags];
        STAssertTrue(player.isMisdiagnosed, @"Player should be misdiagnosed when healt and not shot.");
        STAssertTrue(player.isDead, @"Player should be killed when misdiagnosed twice.");
    }
}


- (void)testPlayerIsNotKilledWhenShotAndGuarded
{
    for (MafiaPlayer *player in self.playerList)
    {
        [self resetPlayerListAndAssignRoles];
        if (player.role != [MafiaRole guardian])
        {
            [player selectByRole:[MafiaRole killer]];
            [player selectByRole:[MafiaRole guardian]];
            [self.settleTagsAction settleTags];
            STAssertFalse(player.isDead, @"Player should not be killed when shot and guarded.");
            STAssertTrue(player.isJustGuarded, @"Player should be just guarded when shot and guarded.");
        }
    }
}


- (void)testGuardianIsKilledWhenGuardedAndShot
{
    [self resetPlayerListAndAssignRoles];
    [self.guardian selectByRole:[MafiaRole guardian]];
    [self.guardian selectByRole:[MafiaRole killer]];
    [self.settleTagsAction settleTags];
    STAssertTrue(self.guardian.isDead, @"Guardian should be killed when guarded and shot.");
}


- (void)testPlayerIsNotMisdiagnosedWhenGuardedAndHealt
{
    for (MafiaPlayer *player in self.playerList)
    {
        [self resetPlayerListAndAssignRoles];
        [player selectByRole:[MafiaRole guardian]];
        [player selectByRole:[MafiaRole doctor]];
        [self.settleTagsAction settleTags];
        STAssertFalse(player.isDead, @"Player should not be killed when guarded and healt.");
        STAssertFalse(player.isMisdiagnosed, @"Player should not be misdiagnosed when guarded and healt.");
        STAssertTrue(player.isJustGuarded, @"Player should be just guarded when guarded and healt.");
    }
}


- (void)testPlayerIsNotMisdiagnosedWhenHealtAndDoctorWasGuarded
{
    for (MafiaPlayer *player in self.playerList)
    {
        [self resetPlayerListAndAssignRoles];
        [self.doctor selectByRole:[MafiaRole guardian]];
        [player selectByRole:[MafiaRole doctor]];
        [self.settleTagsAction settleTags];
        STAssertFalse(player.isMisdiagnosed, @"Player should not be misdiagnosed when healt and doctor was guarded.");
    }
}


- (void)testPlayerIsNotKilledWhenShotAndKillerWasGuarded
{
    for (MafiaPlayer *player in self.playerList)
    {
        [self resetPlayerListAndAssignRoles];
        if (player.role != [MafiaRole guardian])
        {
            [self.killer1 selectByRole:[MafiaRole guardian]];
            [player selectByRole:[MafiaRole killer]];
            [self.settleTagsAction settleTags];
            STAssertFalse(player.isDead, @"Player should not be killed when shot and killer was guarded.");
        }
    }
}


- (void)testGuardianAndKillerAreKilledWhenGuardianWasShotAndKillerWasGuarded
{
    [self resetPlayerListAndAssignRoles];
    [self.killer1 selectByRole:[MafiaRole guardian]];
    [self.guardian selectByRole:[MafiaRole killer]];
    [self.settleTagsAction settleTags];
    STAssertTrue(self.guardian.isDead, @"Guardian should be killed when shot and killer was guarded.");
    STAssertTrue(self.killer1.isDead, @"Killer1 should be killed when guarded and guardian was shot.");
    STAssertFalse(self.killer2.isDead, @"Killer2 should not be killed when killer1 was guarded and guardian was shot.");
}


- (void)testGuardianAndPlayerAreKilledWhenPlayerWasGuardedAndGuardianWasShot
{
    for (MafiaPlayer *player in self.playerList)
    {
        [self resetPlayerListAndAssignRoles];
        [player selectByRole:[MafiaRole guardian]];
        [self.guardian selectByRole:[MafiaRole killer]];
        [self.settleTagsAction settleTags];
        STAssertTrue(self.guardian.isDead, @"Guardian should be killed when shot.");
        STAssertTrue(player.isDead, @"Player should be killed when guarded and guardian was shot.");
    }
}


- (void)testPlayerIsNotKilledOrMisdiagnosedWhenShotAndHealtAndGuarded
{
    for (MafiaPlayer *player in self.playerList)
    {
        [self resetPlayerListAndAssignRoles];
        if (player.role != [MafiaRole guardian])
        {
            [player selectByRole:[MafiaRole guardian]];
            [player selectByRole:[MafiaRole killer]];
            [player selectByRole:[MafiaRole doctor]];
            [self.settleTagsAction settleTags];
            STAssertFalse(player.isDead, @"Player should not be killed when shot and healt and guarded.");
            STAssertFalse(player.isMisdiagnosed, @"Player should not be misdiagnosed when shot and healt and guarded.");
        }
    }
}


- (void)testGuardianIsKilledAndNotMisdiagnosedWhenShotAndHealtAndGuarded
{
    [self resetPlayerListAndAssignRoles];
    [self.guardian selectByRole:[MafiaRole guardian]];
    [self.guardian selectByRole:[MafiaRole killer]];
    [self.guardian selectByRole:[MafiaRole doctor]];
    [self.settleTagsAction settleTags];
    STAssertTrue(self.guardian.isDead, @"Guardian should be killed when shot and healt and guarded.");
    STAssertFalse(self.guardian.isMisdiagnosed, @"Guardian should not be misdiagnosed when shot and healt and guarded.");
}


- (void)testPlayerIsUnguardableWhenGuardedTwiceContinuously
{
    for (MafiaPlayer *player in self.playerList)
    {
        [self resetPlayerListAndAssignRoles];
        // Guarded for the first time.
        [player selectByRole:[MafiaRole guardian]];
        [self.settleTagsAction settleTags];
        STAssertTrue(player.isJustGuarded, @"Player should be just guarded when guarded.");
        STAssertFalse(player.isUnguardable, @"Player should not be unguardable when guarded for the first time.");
        // Guarded for the second time.
        [player selectByRole:[MafiaRole guardian]];
        [self.settleTagsAction settleTags];
        STAssertTrue(player.isJustGuarded, @"Player should be just guarded when guarded.");
        STAssertTrue(player.isUnguardable, @"Player should be unguardable when guarded twice continuously.");
    }
}


- (void)testPlayerIsNotUnguardableWhenGuardedTwiceButNotContinuously
{
    for (MafiaPlayer *player in self.playerList)
    {
        [self resetPlayerListAndAssignRoles];
        // Guarded for the first time.
        [player selectByRole:[MafiaRole guardian]];
        [self.settleTagsAction settleTags];
        STAssertTrue(player.isJustGuarded, @"Player should be just guarded when guarded.");
        STAssertFalse(player.isUnguardable, @"Player should not be unguardable when guarded for the first time.");
        // Not guarded!
        [self.settleTagsAction settleTags];
        STAssertFalse(player.isJustGuarded, @"Player should not be just guarded when not guarded.");
        STAssertFalse(player.isUnguardable, @"Player should not be unguardable when not guarded.");
        // Guarded for the second time, but not continuously.
        [player selectByRole:[MafiaRole guardian]];
        [self.settleTagsAction settleTags];
        STAssertTrue(player.isJustGuarded, @"Player should be just guarded when guarded.");
        STAssertFalse(player.isUnguardable, @"Player should not be unguardable when guarded twice but not continuously.");
    }
}


- (void)testGuardianIsNotKilledOrMisdiagnosedWhenShotAndHealtAndKillerWasGuarded
{
    [self resetPlayerListAndAssignRoles];
    [self.killer1 selectByRole:[MafiaRole guardian]];
    [self.guardian selectByRole:[MafiaRole killer]];
    [self.guardian selectByRole:[MafiaRole doctor]];
    [self.settleTagsAction settleTags];
    STAssertFalse(self.guardian.isDead, @"Guardian should not be killed when shot and healt and killer was guarded.");
    STAssertFalse(self.guardian.isMisdiagnosed, @"Guardian should not be misdiagnosed when shot and healt and killer was guarded.");
    STAssertFalse(self.killer1.isDead, @"Killer1 should not be killed when guarded and guardian was shot and healt.");
}


@end // MafiaSettleTagsActionTests

