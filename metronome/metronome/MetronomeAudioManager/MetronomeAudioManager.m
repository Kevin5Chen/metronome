//
//  MetronomeAudioManager.m
//  metronome
//
//  Created by Kevin on 16/11/18.
//  Copyright © 2016年 com.linlin.kaige.com. All rights reserved.
//

#import "MetronomeAudioManager.h"
#import <AVFoundation/AVFoundation.h>

@interface MetronomeAudioManager ()

@property (strong, nonatomic) AVAudioPlayer *tickPlayer;
@property (strong, nonatomic) AVAudioPlayer *tockPlayer;
@property (assign, nonatomic) NSInteger tickCount;
@property (assign, nonatomic) BOOL isLeft;
@property (assign, nonatomic) NSInteger preBpmValue;

@end

@implementation MetronomeAudioManager



#pragma mark public method

dispatch_source_t _timer ;

- (void)dealloc {
    [_tickPlayer stop];
    _tickPlayer = nil;
    [_tockPlayer stop];
    _tockPlayer = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.tickPlayer prepareToPlay];
        [self.tockPlayer prepareToPlay];
    }
    return self;
}

- (void)play {
    _preBpmValue = _bpmValue;
    self.isPlaying = YES;
    __weak __typeof(self)weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),self.speed*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(!self.isPlaying){
            dispatch_source_cancel(_timer);
        }else{
            [weakSelf playWithLoop];
        }
    });
    dispatch_resume(_timer);
}

- (void)playWithLoop {
    if (!self.isPlaying) {
        return;
    }
    if (_preBpmValue != _bpmValue) {
        _preBpmValue = _bpmValue;
        if (_timer) {
            dispatch_source_cancel(_timer);
            [self play];
        }
        return;
    }
    
    if (self.tickCountBlock) {
        if (self.tickCount>=self.bpcValue) {
            self.tickCount = 0;
        }
        self.tickCountBlock(self.tickCount,self.isLeft);
        self.isLeft = !self.isLeft;
    }
    
    if (0==self.tickCount) {
        self.tickCount++;
        [self.tockPlayer play];
    }else {
        if (self.tickCount < self.bpcValue) {
            self.tickCount++;
            [self.tickPlayer play];
        }else {
            self.tickCount = 1;
            [self.tockPlayer play];
        }
    }
}

- (void)stop {
    self.isPlaying = NO;
    [self.tockPlayer stop];
    [self.tickPlayer stop];
    _tickCount = 0;
    _isLeft = NO;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
}

#pragma mark setter getter
- (AVAudioPlayer *)tickPlayer {
    if (!_tickPlayer) {
        NSString *soundFilePath = [NSString stringWithFormat:@"%@/tick.mp3", [[NSBundle mainBundle]
                                                                              resourcePath]];
        NSURL *url = [NSURL fileURLWithPath:soundFilePath];
        NSError *error;
        _tickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    }
    return _tickPlayer;
}

- (AVAudioPlayer *)tockPlayer {
    if (!_tockPlayer) {
        NSString *soundFilePath = [NSString stringWithFormat:@"%@/tock.mp3", [[NSBundle mainBundle]
                                                                              resourcePath]];
        NSURL *url = [NSURL fileURLWithPath:soundFilePath];
        NSError *error;
        _tockPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    }
    
    return _tockPlayer;
}

- (void)setBpmValue:(NSInteger)bpmValue {
    _preBpmValue = _bpmValue;
    _bpmValue = bpmValue;
    
}

- (float)speed {
    float speed = (60.0 / (float)self.bpmValue);
    return speed;
}

- (float)duration {
    return self.tickPlayer.duration;
}
@end
