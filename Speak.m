//
//  Speak.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/6/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import "Speak.h"
@import AVFoundation;
#import "AudioWrapper.h"


@interface UtterenceHandler : NSObject
@property (nonatomic, weak) AVSpeechUtterance *utterance;
@property (nonatomic, strong) void (^ completionBlock)(BOOL success) ;
@property (nonatomic, strong) void (^ startSpeakingBlock)(void);
@end
@implementation UtterenceHandler
@end


@interface Speak()
@property (nonatomic, strong) AVSpeechSynthesizer *synth;
@property (nonatomic) float speechRate;
@property (nonatomic, strong) NSMutableArray *listOfUtterenceHandlers;
@end

@implementation Speak
@synthesize listOfUtterenceHandlers;
-(NSMutableArray*) listOfUtterenceHandlers{
    if (listOfUtterenceHandlers == nil) {
        listOfUtterenceHandlers = [[NSMutableArray alloc]init];
    }
    return listOfUtterenceHandlers;
}


+(Speak *)sharedSpeak{
    static Speak *shared = nil;
    
    if (shared==nil) {
        shared = [[super allocWithZone:NULL] init];
        
        // set up the voice baby
        shared.speechRate = AVSpeechUtteranceMinimumSpeechRate + ((AVSpeechUtteranceDefaultSpeechRate - AVSpeechUtteranceMinimumSpeechRate) *0.25);

        //utterance.voice =
        shared.synth = [[AVSpeechSynthesizer alloc] init];
        shared.synth.delegate = shared;
        
    }
    return shared;
    
}


//
-(void)say:(id)words{
    [self say:words completionBlock:nil];
}
-(void)say:(id)words completionBlock:(void (^)(BOOL success))completionBlock{
    [self say:words startSpeakingBlock:nil completionBlock:completionBlock];
}



-(void)say:(id)words startSpeakingBlock:(void (^)(void))startSpeakingBlock completionBlock:(void (^)(BOOL success))completionBlock{
    
    if([words isKindOfClass:[AudioElement class]]) {
        AudioElement* thisElement = words;
        
        if (thisElement.doesExist) {
            // use sample
            [[AudioWrapper sharedAudio] playback:words completeBlock:^(BOOL success) {
                if (completionBlock) completionBlock(success);
            }];
            if (startSpeakingBlock) startSpeakingBlock();
        } else if (thisElement.textToSpeach) {
            // use computer voice
            [self sayWithComputerVoice:thisElement.textToSpeach startSpeakingBlock:startSpeakingBlock completionBlock:completionBlock];
        }
    } else if([words isKindOfClass:[NSString class]]) {
        // use computer voice
        [self sayWithComputerVoice:words startSpeakingBlock:startSpeakingBlock completionBlock:completionBlock];
    } else {
        // Unknown type
        NSLog(@"Speak->Say: ERROR unsuported words objects type:'%@'", [words class]);
        if (startSpeakingBlock) startSpeakingBlock();
        if (completionBlock) completionBlock(NO);
    }
}

-(void)sayWithComputerVoice:(NSString*)thisString startSpeakingBlock:(void (^)(void))startSpeakingBlock completionBlock:(void (^)(BOOL success))completionBlock{

    AVSpeechUtterance *utterance = nil;
    utterance = [AVSpeechUtterance speechUtteranceWithString:thisString];
    utterance.rate = self.speechRate;
    [self.synth speakUtterance:utterance];
    
    if (completionBlock || startSpeakingBlock) {
        UtterenceHandler *handler = [[UtterenceHandler alloc]init];
        handler.utterance = utterance;
        handler.completionBlock = completionBlock;
        handler.startSpeakingBlock = startSpeakingBlock;
        [self.listOfUtterenceHandlers addObject:handler];
    }}


-(void)stop{
    // stop
    [self.synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    [[AudioWrapper sharedAudio]playbackStop];
    
    // remove all objects
    [self.listOfUtterenceHandlers removeAllObjects];
}


-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {

    [self.listOfUtterenceHandlers enumerateObjectsUsingBlock:^(UtterenceHandler *handler, NSUInteger idx, BOOL *stop) {
        
        if (handler.utterance == utterance) {
            if (handler.startSpeakingBlock) {
                handler.startSpeakingBlock();
            }
        }
    }];

    
}



- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    
    __block UtterenceHandler *toRemove = nil;
    
    [self.listOfUtterenceHandlers enumerateObjectsUsingBlock:^(UtterenceHandler *handler, NSUInteger idx, BOOL *stop) {
        
        if (handler.utterance == utterance) {
            if (handler.completionBlock) {
                handler.completionBlock(YES);
            }
            
            toRemove = handler;
        }
    }];
    
    if (toRemove) {
        [self.listOfUtterenceHandlers removeObject:toRemove];
    }
    
}


@end
