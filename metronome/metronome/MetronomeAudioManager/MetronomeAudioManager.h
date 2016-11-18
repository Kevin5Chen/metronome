//
//  MetronomeAudioManager.h
//  metronome
//
//  Created by Kevin on 16/11/18.
//  Copyright © 2016年 com.linlin.kaige.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MetronomeAudioManagerTickCount)(NSInteger tickCount,BOOL isLeft);

@interface MetronomeAudioManager : NSObject

- (void)play;
- (void)stop;
@property (assign, nonatomic) NSInteger bpmValue;
@property (assign, nonatomic) NSInteger bpcValue;
@property (copy, nonatomic) MetronomeAudioManagerTickCount tickCountBlock;
@property (assign, nonatomic) BOOL isPlaying;
@property(nonatomic,assign)float speed;
@property(nonatomic,assign)float duration;

@end
