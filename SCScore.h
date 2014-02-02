//
//  SCScore.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 12/20/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCDatabase.h"
#import "SCAssessment.h"

//typedef enum {
//	CorrectAnswerIsPrompt = 0,
//	CorrectAnswerIsCorrectTarget
//} SCScoreMode;

@interface SCScore : NSObject
+(SCScore*)sharedScore;


//-(void)initaliseBattery:(SCBattery*)thisBattery andSubjectName:(NSString*)name DOB:(NSDate*)DOB forThisUser:(id)user;
-(void)initaliseBattery:(SCBattery*)thisBattery forTestInstance:(SCAssessment*)thisTestInstance;
-(void)abortBattery;
-(void)endBattery;
                                                                
                                                                
-(void)startTimerForTest:(SCTest*)thisTest;
-(NSTimeInterval)elapsedTimeForCurrentTest;
-(void)startTimerForPage:(SCPage*)thisPage;
-(void)recordResultForCurrentPage:(SCElement*)answer;
-(void)recordResultsForCurrentPage:(NSArray*)answers;
-(void)stopAndRecordResultsForCurrentTest;
-(void)invalidateResultsForCurrentTest;
//-----
-(NSInteger)correctAnswersForCurrentTest;
-(NSInteger)incorrectAnswersForCurrentTest;
-(NSInteger)answersForCurrentTest;
-(NSTimeInterval)timeForCurrentTest;
-(NSInteger)correctAnswersForTest:(SCTest*)thisTest;
-(NSInteger)incorrectAnswersForTest:(SCTest*)thisTest;
-(NSInteger)answersForTest:(SCTest*)thisTest;
-(NSTimeInterval)timeForTest:(SCTest*)thisTest;
-(BOOL)isCurrentPageValid;
-(BOOL)wasPageAnsweredCorrectly:(SCPage*)thisPage;
@end
