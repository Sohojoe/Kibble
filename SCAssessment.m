//
//  SCAssessment.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 1/28/14.
//  Copyright (c) 2014 Vidya Gamer, LLC. All rights reserved.
//

#import "SCAssessment.h"
#import "User.h"
#import "Install.h"

@implementation SCAssessment
@synthesize age,ageInMonths,ageInYears,testDate;
@synthesize user;
@synthesize isComplete;
@synthesize dOBAsTextString;
@synthesize firstName,dOB,notes, outcome;



//---------------
// slot functions
static NSMutableArray *staticSlots;
+(int)numberOfAssessments{
    return 4;
}
+(SCAssessment*)assessmentAtSlot:(int)thisSlot{
    SCAssessment *assessment = nil;
    if (thisSlot<[self numberOfAssessments]) {
        assessment = [[self slots] objectAtIndex:thisSlot];
    }
    return (assessment);
}
+(void)setAssessmentAtSlot:(int)thisSlot toAssessment:(SCAssessment*)thisAssessment{
    [[self slots] replaceObjectAtIndex:thisSlot withObject:thisAssessment];
    // save out the slots
    [self saveOutTheSlots];
}
+(NSMutableArray *)slots{
    if (staticSlots==nil) {
        // lazy init slots
        staticSlots = [[NSMutableArray alloc]init];
        while (staticSlots.count < [self numberOfAssessments]) {
            [staticSlots addObject:[[SCAssessment alloc]init]];
        }
        [self loadTheSlots];
    }
    return (staticSlots);
}

//-------------------------------------------------------------------------------------
// handle saving and loading
+(void)saveOutTheSlots{
    [staticSlots enumerateObjectsUsingBlock:^(SCAssessment *thisAssessment, NSUInteger idx, BOOL *stop) {
        [thisAssessment saveAsSlotNumber:idx];
    }];
}
#define version 1
-(void)saveAsSlotNumber:(NSUInteger)thisSlot{
    
    NSString *preKey = [NSString stringWithFormat:@"SCAssessment_version%d_slot%lu", version, (unsigned long)thisSlot];
    
    [self saveObject:self.firstName forKey:@"firstName" andPreKey:preKey];
    [self saveObject:self.dOB forKey:@"dOB" andPreKey:preKey];
    [self saveObject:self.notes forKey:@"notes" andPreKey:preKey];
    [self saveObject:self.testDate forKey:@"testDate" andPreKey:preKey];
    [self saveObject:self.outcome forKey:@"outcome" andPreKey:preKey];
    [self saveObject:self.user forKey:@"user" andPreKey:preKey];
}
-(void)saveObject:(id)obj forKey:(NSString*)objectKey andPreKey:(NSString*)preKey{
    [[Install sharedInstall] store:obj forKey:[NSString stringWithFormat:@"%@_%@", preKey, objectKey]];
}
-(void)saveIfIAmASlot{
    NSUInteger index = [staticSlots indexOfObject:self];
    if (index != NSNotFound) {
        [self saveAsSlotNumber:index];
    }
}
+(void)loadTheSlots{
    [staticSlots enumerateObjectsUsingBlock:^(SCAssessment *thisAssessment, NSUInteger idx, BOOL *stop) {
        [thisAssessment loadSlotsNumber:idx];
    }];
}
-(void)loadSlotsNumber:(NSUInteger) idx{
    NSString *preKey = [NSString stringWithFormat:@"SCAssessment_version%d_slot%lu", version, (unsigned long)idx];
    
    firstName = [self loadObjectForKey:@"firstName" andPreKey:preKey];
    dOB = [self loadObjectForKey:@"dOB" andPreKey:preKey];
    notes = [self loadObjectForKey:@"notes" andPreKey:preKey];
    testDate = [self loadObjectForKey:@"testDate" andPreKey:preKey];
    outcome = [self loadObjectForKey:@"outcome" andPreKey:preKey];
    user = [self loadObjectForKey:@"user" andPreKey:preKey];
}
-(id)loadObjectForKey:(NSString*)objectKey andPreKey:(NSString*)preKey{
    id obj = [[Install sharedInstall] getForKey:[NSString stringWithFormat:@"%@_%@", preKey, objectKey]];
    return obj;
}
//-------------------------------------------------------------------------------------
//
+(void)removeThisAssessmentFromSlots:(SCAssessment*)thisAssessment{
    if (thisAssessment) {
        [staticSlots removeObject:thisAssessment];
    }
    // repalace missing slots
    while (staticSlots.count < [self numberOfAssessments]) {
        [staticSlots addObject:[[SCAssessment alloc]init]];
    }
    // save out the slots
    [self saveOutTheSlots];
}
static SCAssessment *theActiveAssessment;
+(SCAssessment*)activeAssessment{
    return (theActiveAssessment);
}
+(void)setActiveAssessment:(SCAssessment*)thisAssessment{
    theActiveAssessment = thisAssessment;
}



//-------------------------------------------------------------------------------------
//

-(BOOL)isComplete{
    BOOL result = (BOOL)self.outcome;
    return result;
}

//---

-(float)age{
    float thisAge = self.ageInMonths - (self.ageInYears*12);
    thisAge /= 12;
    thisAge += self.ageInYears;
    return (thisAge);
}
-(int)ageInYears{
    return ([self yearsBetween:self.dOB and:[NSDate date]]);
}
-(int)ageInMonths{
    return ([self monthsBetween:self.dOB and:[NSDate date]]);
}
-(NSDate*)testDate{
    if (testDate == nil) {
        testDate = [NSDate date];
    }
    return testDate;
}
-(void)setTestDate:(NSDate *)thisTestDate{
    testDate = thisTestDate;
    [self saveIfIAmASlot];
}

-(id)user{
    if (user == nil){
        user = [User activeUser].emailAddress;
    }
    return (user);
}
-(void)setUser:(NSString *)thisUser{
    user = thisUser;
    [self saveIfIAmASlot];
}
-(void)setFirstName:(NSString *)thisFirstName{
    firstName = thisFirstName;
    [self saveIfIAmASlot];
}
-(void)setDOB:(NSDate *)thisDOB{
    dOB = thisDOB;
    [self saveIfIAmASlot];
}
-(void)setNotes:(NSString *)thisNotes{
    notes = thisNotes;
    [self saveIfIAmASlot];
}
-(void)setOutcome:(NSString *)thisOutcome{
    outcome = thisOutcome;
    [self saveIfIAmASlot];
}
-(NSString*)dOBAsTextString{
    dOBAsTextString = [NSDateFormatter localizedStringFromDate:self.dOB dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
    return (dOBAsTextString);
}


//-----
// helper functions
- (int)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    return ((int)[components day]);
}
- (int)monthsBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
    NSUInteger unitFlags = NSMonthCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    return ((int)[components month]);
}
- (int)yearsBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
    NSUInteger unitFlags = NSYearCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    return ((int)[components year]);
}

@end
