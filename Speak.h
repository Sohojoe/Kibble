//
//  Speak.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/6/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVSpeechSynthesis.h"


@interface Speak : NSObject <AVSpeechSynthesizerDelegate>

+(Speak *)sharedSpeak;



-(void)say:(id)words;
-(void)say:(id)words completionBlock:(void (^)(BOOL success))completionBlock;
-(void)say:(id)words startSpeakingBlock:(void (^)(void))startSpeakingBlock completionBlock:(void (^)(BOOL success))completionBlock;
-(void)stop;


@end
