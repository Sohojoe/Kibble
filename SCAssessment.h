//
//  SCAssessment.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 1/28/14.
//  Copyright (c) 2014 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCAssessment : NSObject
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSDate* dOB;
@property (nonatomic, strong) NSString* notes;
@property (nonatomic, strong) NSDate* testDate;
@property (nonatomic, strong) NSString* outcome;
@property (nonatomic, strong) NSString* user;
@property (nonatomic, readonly) float age;
@property (nonatomic, readonly) int ageInYears;
@property (nonatomic, readonly) int ageInMonths;
@property (nonatomic, readonly) BOOL isComplete;
@property (nonatomic, weak, readonly) NSString* dOBAsTextString;

// Class functions to handle slots
+(int)numberOfAssessments;
+(SCAssessment*)assessmentAtSlot:(int)thisSlot;
+(void)setAssessmentAtSlot:(int)thisSlot toAssessment:(SCAssessment*)thisAssessment;
+(void)removeThisAssessmentFromSlots:(SCAssessment*)thisAssessment;
+(SCAssessment*)activeAssessment;
+(void)setActiveAssessment:(SCAssessment*)thisAssessment;


@end
