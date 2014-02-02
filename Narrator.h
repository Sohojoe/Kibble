//
//  Narrator.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/15/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Narrator : UIButton

#define NarratorYPercent 0.30
#define TargetYPercent 0.75
#define TargetYPercentWhenSpeakers 0.70
#define TargetTopYPercent 0.30
#define TargetBottomYPercent 0.70
#define NarratorXPercent 0.30
#define PromptXPercent 0.666

//#define NarratorYPercent 0.25
//#define TargetYPercent 0.75
//#define TargetYPercentWhenSpeakers 0.70
//#define TargetTopYPercent 0.25
//#define TargetBottomYPercent 0.70
//#define NarratorXPercent 0.25
//#define PromptXPercent 0.716

#define NarratorHighYPercent 0.20


#define NarratorSquareXPercent 0.15
#define NarratorSquareYPercent 0.50
#define MAXMAXWIDTH 256


+(Narrator*)sharedNarrator;

-(void)initAt:(CGPoint)pos after:(float)delay;
-(void)moveTo:(CGPoint)pos isAnimated:(BOOL)isAnimated;

-(void)say:(id)words;
-(void)say:(id)words completionBlock:(void (^)(BOOL success))completionBlock;
-(void)say:(id)words startSpeakingBlock:(void (^)(void))startSpeakingBlock completionBlock:(void (^)(BOOL success))completionBlock;
-(void)stop;

@end
