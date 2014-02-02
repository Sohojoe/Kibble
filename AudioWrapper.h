//
//  AudioWrapper.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/28/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@interface AudioElement : NSObject
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, readonly) BOOL doesExist;
@property (nonatomic, readonly) NSString *actualPathAndFile;
@property (nonatomic, readonly) NSString *actualPath;
@property (nonatomic, readonly) NSString *actualFileName;
@property (nonatomic, readonly) NSDate *fileDate;
@property (nonatomic, strong) NSString *textToSpeach;
-(AudioElement*)initWithPath:(NSString*)thisPath
                    fileName:(NSString*)thisFileName
                textToSpeach:(NSString*)thisTextToSpeach;
@end

@interface AudioWrapper : NSObject <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

+(AudioWrapper *)sharedAudio;
-(void)playKeyClickDown;
-(void)playKeyClickUp;
-(void)startMetering:(void (^)(float aveagePower, float peakPower))meteringBlock;
-(void)stopMetering;

-(void) record:(AudioElement*)audio;
-(void) record:(AudioElement*)audio completeBlock:(void (^)(AudioElement* recordedAudio, BOOL success))completeBlock;
-(void) recordStop;
-(void) playback:(AudioElement*)audio;
-(void) playback:(AudioElement*)audio completeBlock:(void (^)(BOOL success))completeBlock;
-(void) playbackStop;
@end
