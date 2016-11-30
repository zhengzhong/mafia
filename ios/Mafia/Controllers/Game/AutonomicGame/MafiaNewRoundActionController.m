//
//  Created by ZHENG Zhong on 2016-11-30.
//  Copyright (c) 2016 ZHENG Zhong. All rights reserved.
//

#import "MafiaNewRoundActionController.h"

#import "MafiaGameplay.h"
#import "UINavigationItem+MafiaBackTitle.h"

#import <AVFoundation/AVFoundation.h>


@interface MafiaNewRoundActionController () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end


@implementation MafiaNewRoundActionController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem mafia_clearBackTitle];
    self.navigationItem.hidesBackButton = YES;
    self.title = NSLocalizedString(@"New Round", nil);

    // TODO: Add audio file!
    self.audioPlayer = [self mafia_createAudioPlayerForAudio:@"new_round_wenwen"];
    self.audioPlayer.delegate = self;

    self.isStarted = NO;
    self.messageLabel.text = NSLocalizedString(@"Night is coming...", nil);
    [self.startDoneButton setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
}


#pragma mark - Actions


- (IBAction)startDoneButtonTapped:(id)sender {
    if (!self.isStarted) {
        self.isStarted = YES;
        [self.startDoneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        [self.audioPlayer play];
    } else {
        [self.audioPlayer stop];
        self.audioPlayer.currentTime = 0;
        [self.delegate autonomicActionControllerDidCompleteAction:self];
    }
}


- (void)setupWithGame:(MafiaGame *)game {
    self.game = game;
    self.isStarted = NO;
}


#pragma mark - AVAudioPlayerDelegate


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"Audio player did finish playing: successfully ? %@", (flag ? @"YES" : @"NO"));
    self.messageLabel.text = NSLocalizedString(@"A new round begins.", nil);
}


- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Fail to decode audio: %@", error);
}


#pragma mark - Private


- (AVAudioPlayer *)mafia_createAudioPlayerForAudio:(NSString *)audioName {
    NSString *soundPath =[[NSBundle mainBundle] pathForResource:audioName ofType:@"m4a"];
    if (soundPath == nil) {
        NSLog(@"Cannot load audio resource: %@.m4a", audioName);
        return nil;
    }
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    if (error != nil) {
        NSLog(@"Fail to create audio player for audio %@: %@", audioName, error);
        return nil;
    }
    return player;
}


@end
