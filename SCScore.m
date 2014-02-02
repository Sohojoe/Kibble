//
//  SCScore.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 12/20/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import "SCScore.h"
#import "Parse.framework/Headers/Parse.h"
#import "Local.h"

#define DEBUG_STRINGS

//-------------------------
@interface TestScoreElement : NSObject
@property (nonatomic, strong) SCTest *thisTest;
@property (nonatomic) NSTimeInterval timeForTest;
@property (nonatomic) NSInteger correctAnswers;
@property (nonatomic) NSInteger incorrectAnswers;
@property (nonatomic, strong) NSMutableArray *pageScores;
@property (nonatomic, strong) id testScoreObjectID;
@end
@implementation TestScoreElement
/*@synthesize pageScoreElements;
-(NSMutableArray*)pageScoreElements{
    if (pageScoreElements == nil) {
        pageScoreElements = [[NSMutableArray alloc]init];
    }
    return pageScoreElements;
}*/
@end
//-------------------------
@interface PageScoreElement : NSObject
@property (nonatomic, strong) SCPage *thisPage;
@property (nonatomic, strong) SCTest *thisTest;
@property (nonatomic, strong) SCElement *answer;
@property (nonatomic, strong) NSArray *answers;
@property (nonatomic, readonly) BOOL answerIsCorrect;
@property (nonatomic, readonly) BOOL answerEqualsPrompt;
@property (nonatomic, readonly) BOOL answerEqualsCorrectTarget;
@property (nonatomic) NSTimeInterval timeForPage;
@property (nonatomic, strong) id pageScoreObjectID;
@end
@implementation PageScoreElement
@synthesize answerIsCorrect, answerEqualsPrompt, answerEqualsCorrectTarget;
-(BOOL)answerIsCorrect{
    BOOL isCorrect = NO;
    
    if (self.answers) {
        isCorrect = [self answersEqualTargets];
    } else if (self.thisTest.compareAnswerWithCorrectTarget) {
        isCorrect = [self answerEqualsCorrectTarget];
    } else {
        isCorrect = [self answerEqualsPrompt];
    }
    return isCorrect;
}
-(BOOL)answerEqualsPrompt{
    BOOL isCorrect = NO;
    if (self.answer == self.thisPage.prompt) {
        isCorrect = YES;
    }
    return isCorrect;
}
-(BOOL)answerEqualsCorrectTarget{
    BOOL isCorrect = NO;
    if (self.answer == [self.thisPage.targets objectAtIndex:self.thisPage.correctTarget]) {
        isCorrect = YES;
    }
    return isCorrect;
}
-(BOOL)answersEqualTargets{
    BOOL isCorrect = NO;
    
    if (self.answers.count == self.thisPage.targets.count) {
        __block int correctAnswers = 0;
        [self.thisPage.targets enumerateObjectsUsingBlock:^(SCElement *targetElement, NSUInteger idx, BOOL *stop) {
            if ([self.answers objectAtIndex:idx] == targetElement) {
                correctAnswers++;
            }
        }];
        if (correctAnswers == self.thisPage.targets.count) {
            isCorrect = YES;
        }
    }
    return isCorrect;
}
//compareAnswerWithCorrectTarget
@end

//---------------------------------------------------------------------------
//
@interface SCScore ()
@property (nonatomic, strong) NSMutableDictionary *testScores;
@property (nonatomic, strong) NSMutableArray *pageScores;
@property (nonatomic, strong) SCTest *currentTest;
@property (nonatomic) NSTimeInterval currentTestStartTime;
@property (nonatomic, strong) SCPage *currentPage;
@property (nonatomic) NSTimeInterval currentPageStartTime;

@property (nonatomic, strong) SCAssessment *assessmentInstance;
//@property (nonatomic, strong) NSString* firstName;
//@property (nonatomic, strong) NSDate* dateOfBirth;
//@property (nonatomic, strong) NSNumber* age;
@property (nonatomic, strong) id batteryScoreObjectID;
@property (nonatomic, strong) id testScoreObjectID;
@property (nonatomic, strong) SCBattery *battery;
//@property (nonatomic, strong) id user;



@end

@implementation SCScore
@synthesize testScores;
-(NSMutableDictionary*)testScores{
    if (testScores == nil) {
        testScores = [[NSMutableDictionary alloc]init];
    }
    return testScores;
}

+(SCScore*)sharedScore{
    static SCScore *shared = nil;
    
    if (shared==nil) {
        // first Time Init
        shared = [[super allocWithZone:NULL] init];
    }
    return shared;
}

//-------------------------
-(void)startTimerForTest:(SCTest*)thisTest{
    if (self.currentTest != thisTest) {
        self.currentTest = thisTest;
        self.currentTestStartTime = [NSDate timeIntervalSinceReferenceDate];
        self.pageScores = [[NSMutableArray alloc]init];
        
        #ifdef DEBUG_STRINGS
        NSLog(@"SCScore:startTimerForTest timer starting for '%@'", thisTest.name);
        #endif


        [self uploadTestScoreStart];
    }
}
-(NSTimeInterval)elapsedTimeForCurrentTest{
    NSTimeInterval elapsedTime = [NSDate timeIntervalSinceReferenceDate] - self.currentTestStartTime;
    return (elapsedTime);
}
-(void)startTimerForPage:(SCPage*)thisPage{
    if (self.currentPage) {
        NSLog(@"SCScore:startTimerForPage ERROR page'%@' did not stopped recording when new page '%@' called", self.currentPage, thisPage);
    }
    self.currentPage = thisPage;
    self.currentPageStartTime = [NSDate timeIntervalSinceReferenceDate];

    #ifdef DEBUG_STRINGS
    NSLog(@"SCScore:startTimerForPage timer starting for '%@'", thisPage.name);
    #endif
}

-(void)recordResultForCurrentPage:(SCElement*)answer{
    if ([self isCurrentPageValid] == NO) {
        NSLog(@"SCScore:recordResultForCurrentPage ERROR startTime was no called for current page - no results to record");
        return;
    }
    
    PageScoreElement *pageScore = [[PageScoreElement alloc]init];
    pageScore.thisPage = self.currentPage;
    pageScore.thisTest = self.currentTest;
    pageScore.answer = answer;
    pageScore.timeForPage = [NSDate timeIntervalSinceReferenceDate] - self.currentPageStartTime;
    [self.pageScores addObject:pageScore];
    
    #ifdef DEBUG_STRINGS
    NSLog(@"SCScore:recordResultForCurrentPage page '%@' complete in %f seconds", self.currentPage.name, pageScore.timeForPage);
    if (pageScore.answerIsCorrect) {
        NSLog(@"SCScore:recordResultForCurrentPage %@ was correctAnswer = YES", answer.name);
    } else {
        NSLog(@"SCScore:recordResultForCurrentPage %@ was correctAnswer = NO", answer.name);
    }
    #endif
    
    // upload to server
    [self uploadPageScoreEnd:pageScore];
    
    self.currentPage = nil;
}
-(void)recordResultsForCurrentPage:(NSArray *)answers{
    if ([self isCurrentPageValid] == NO) {
        NSLog(@"SCScore:recordResultsForCurrentPage ERROR startTime was no called for current page - no results to record");
        return;
    }
    PageScoreElement *pageScore = [[PageScoreElement alloc]init];
    pageScore.thisPage = self.currentPage;
    pageScore.thisTest = self.currentTest;
    pageScore.answers = answers;
    pageScore.timeForPage = [NSDate timeIntervalSinceReferenceDate] - self.currentPageStartTime;
    [self.pageScores addObject:pageScore];
    
#ifdef DEBUG_STRINGS
    NSLog(@"SCScore:recordResultForCurrentPage page '%@' complete in %f seconds", self.currentPage.name, pageScore.timeForPage);
    __block NSString *answerString = [[NSString alloc]init];
    [answers enumerateObjectsUsingBlock:^(SCElement *answer, NSUInteger idx, BOOL *stop) {
        answerString = [NSString stringWithFormat:@"%@+%@", answerString, answer.name];
    }];
    if (pageScore.answerIsCorrect) {
        NSLog(@"SCScore:recordResultsForCurrentPage %@ was correctAnswer = YES", answerString);
    } else {
        NSLog(@"SCScore:recordResultsForCurrentPage %@ was correctAnswer = NO", answerString);
    }
#endif

    // upload to server
    [self uploadPageScoreEnd:pageScore];

    self.currentPage = nil;
}


-(void)stopAndRecordResultsForCurrentTest{
    TestScoreElement *testScore = [[TestScoreElement alloc]init];
    testScore.thisTest = self.currentTest;
    testScore.timeForTest = [NSDate timeIntervalSinceReferenceDate] - self.currentTestStartTime;
    testScore.pageScores = self.pageScores;
    
    [testScore.pageScores enumerateObjectsUsingBlock:^(PageScoreElement *pageScore, NSUInteger idx, BOOL *stop) {
        if (pageScore.answerIsCorrect) {
            testScore.correctAnswers++;
        } else {
            testScore.incorrectAnswers++;
        }
    }];
    
    [self.testScores setObject:testScore forKey:testScore.thisTest.name];
    
    #ifdef DEBUG_STRINGS
    NSLog(@"SCScore:stopAndRecordResultsForCurrentTest test '%@' complete in %f secords", self.currentTest.name, testScore.timeForTest);
    NSLog(@"%ld corrects answers out of %ld total answers", (long)[self correctAnswersForTest:testScore.thisTest], (long)[self answersForTest:testScore.thisTest]);
    float aveAnswerTime = [self timeForTest:testScore.thisTest] / [self answersForTest:testScore.thisTest];
    NSLog(@"average of %f seconds per answer", aveAnswerTime);
    #endif

    // upload to server
    [self uploadTestScoreEnd:testScore];

    
    self.currentTest = nil;
    self.pageScores = nil;
}

-(void)invalidateResultsForCurrentTest{
    #ifdef DEBUG_STRINGS
    NSLog(@"SCScore:invalidateResultsForCurrentTest test '%@' was invalidated", self.currentTest);
    #endif
    
    self.currentTest = nil;
    self.pageScores = nil;
}


//----------------------------------------------------------------------------------------------------
//helper functions
-(NSInteger)correctAnswersForCurrentTest{
    __block NSInteger correct = 0;
    [self.pageScores enumerateObjectsUsingBlock:^(PageScoreElement *pageScore, NSUInteger idx, BOOL *stop) {
        if ([pageScore answerIsCorrect]) {
            correct++;
        }
    }];
    return (correct);
}
-(NSInteger)incorrectAnswersForCurrentTest{
    __block NSInteger incorrect = 0;
    [self.pageScores enumerateObjectsUsingBlock:^(PageScoreElement *pageScore, NSUInteger idx, BOOL *stop) {
        if ([pageScore answerIsCorrect] == NO) {
            incorrect++;
        }
    }];
    return (incorrect);
}
-(NSInteger)answersForCurrentTest{
    return (self.pageScores.count);
}
-(NSTimeInterval)timeForCurrentTest{
    return (self.timeForCurrentTest);
}

-(NSInteger)correctAnswersForTest:(SCTest*)thisTest{
    TestScoreElement *testScore = [self.testScores objectForKey:thisTest.name];
    return (testScore.correctAnswers);
}
-(NSInteger)incorrectAnswersForTest:(SCTest*)thisTest{
    TestScoreElement *testScore = [self.testScores objectForKey:thisTest.name];
    return (testScore.incorrectAnswers);
}
-(NSInteger)answersForTest:(SCTest*)thisTest{
    TestScoreElement *testScore = [self.testScores objectForKey:thisTest.name];
    return (testScore.correctAnswers + testScore.incorrectAnswers);
}
-(NSTimeInterval)timeForTest:(SCTest *)thisTest{
    TestScoreElement *testScore = [self.testScores objectForKey:thisTest.name];
    return (testScore.timeForTest + testScore.incorrectAnswers);
}
-(BOOL)isCurrentPageValid{
    return (self.currentPage) ? YES : NO;
}
-(BOOL)wasPageAnsweredCorrectly:(SCPage*)thisPage{
    __block PageScoreElement *correctPageScore = nil;
    
    [self.pageScores enumerateObjectsUsingBlock:^(PageScoreElement *thisPageScore, NSUInteger idx, BOOL *stop) {
        if (thisPageScore.thisPage == thisPage) {
            correctPageScore = thisPageScore;
        }
    }];

    return correctPageScore.answerIsCorrect;
}

//--------------------------------------
//
//-(void)initaliseBattery:(SCBattery*)thisBattery andSubjectName:(NSString*)name DOB:(NSDate*)dOB forThisUser:(id)user{
-(void)initaliseBattery:(SCBattery*)thisBattery forTestInstance:(SCAssessment*)thisTestInstance{
    self.battery = thisBattery;
    self.assessmentInstance = thisTestInstance;
    
    [self uploadBatteryScoreStart];
}
-(void)abortBattery{
    [self uploadBatterScoreAbort];
    [self invalidateResultsForCurrentTest];
}
-(void)endBattery{
    self.assessmentInstance.outcome = LocalString(@"Assessment complete!\n\nThis data has been uploaded to our servers and will be used to help us validate the app against traditional pen and paper testing.\n\nAfter taking the test in the final app, the app will provide a likely hood of a dyslexic cognitive profile and give suggestions based on our research and experience.\n\nPlease join our community at dyslexicadvantage.com");
    [self uploadBatterScoreEnd];
}

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

//--------------------------------------
//
-(void)uploadBatteryScoreStart{
    // early exit if there is not a valid assessmentInstance
    if (self.assessmentInstance == nil) return;

    PFObject *batteryScore = [PFObject objectWithClassName:@"zdBatteryScores"];
    self.batteryScoreObjectID = batteryScore;
    if (self.battery.name) batteryScore[@"battery"] = self.battery.name;
    if (self.assessmentInstance.firstName) batteryScore[@"subjectFirstName"] = self.assessmentInstance.firstName;
    if (self.assessmentInstance.dOB) batteryScore[@"subjectDOB"] = self.assessmentInstance.dOB;
    if (self.assessmentInstance.notes) batteryScore[@"subjectNotes"] = self.assessmentInstance.notes;
    if (self.assessmentInstance.user) batteryScore[@"user"] = self.assessmentInstance.user;
    batteryScore[@"subjectAge"] = [NSNumber numberWithFloat:self.assessmentInstance.age];
    batteryScore[@"startTime"] = [NSDate date];
    [batteryScore saveEventually];
}
-(void)uploadBatterScoreEnd{
    // early exit if there is not a valid assessmentInstance
    if (self.assessmentInstance == nil) return;

    PFObject *batteryScore = self.batteryScoreObjectID;
    
    batteryScore[@"endTime"] = [NSDate date];
    if (self.assessmentInstance.outcome) batteryScore[@"resultString"] = self.assessmentInstance.outcome;
    
    [batteryScore saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFRelation *relation = [batteryScore relationforKey:@"testScoreIDs"];
            [self.testScores enumerateKeysAndObjectsUsingBlock:^(id key, TestScoreElement *testScoreElement, BOOL *stop) {
                [relation addObject:testScoreElement.testScoreObjectID];
            }];
            [batteryScore saveEventually];
        }
    }];
}
-(void)uploadBatterScoreAbort{
    // early exit if there is not a valid assessmentInstance
    if (self.assessmentInstance == nil) return;

    PFObject *batteryScore = self.batteryScoreObjectID;
    
    batteryScore[@"resultString"] = [NSString stringWithFormat:@"Battary was aborted at %@", [NSDate date]];
    
    [batteryScore saveEventually];
}

-(void)uploadTestScoreStart{
    // early exit if there is not a valid assessmentInstance
    if (self.assessmentInstance == nil) return;
    
    PFObject *testScore = [PFObject objectWithClassName:@"zdTestScores"];
    self.testScoreObjectID = testScore;
}
-(void)uploadTestScoreEnd:(TestScoreElement*)thisTestScoreElement{
    // early exit if there is not a valid assessmentInstance
    if (self.assessmentInstance == nil) return;
    
    PFObject *testScore = self.testScoreObjectID;
    //PFObject *testScore = [PFObject objectWithClassName:@"testScores"];
    thisTestScoreElement.testScoreObjectID = testScore;


    if (self.battery.name) testScore[@"battery"] = self.battery.name;
    if (self.batteryScoreObjectID) testScore[@"batteryScoreID"] = self.batteryScoreObjectID;
    if (self.assessmentInstance.firstName) testScore[@"subjectFirstName"] = self.assessmentInstance.firstName;
    if (self.assessmentInstance.dOB) testScore[@"subjectDOB"] = self.assessmentInstance.dOB;
    testScore[@"subjectAge"] = [NSNumber numberWithFloat:self.assessmentInstance.age];
    if (thisTestScoreElement.thisTest.name) testScore[@"test"] = thisTestScoreElement.thisTest.name;
    
    double time = round(100 * thisTestScoreElement.timeForTest) / 100;
    testScore[@"time"] = [NSNumber numberWithDouble:time];

    
    testScore[@"correctAnswers"] = [NSNumber numberWithInt:thisTestScoreElement.correctAnswers];
    testScore[@"incorrectAnswers"] = [NSNumber numberWithInt:thisTestScoreElement.incorrectAnswers];
    testScore[@"totalAnswers"] = [NSNumber numberWithInt:(thisTestScoreElement.correctAnswers + thisTestScoreElement.incorrectAnswers)];
    
/*    PFRelation *relation = [testScore relationforKey:@"pageScoreIDs"];
    [thisTestScoreElement.pageScores enumerateObjectsUsingBlock:^(PageScoreElement *pageScoreElement, NSUInteger idx, BOOL *stop) {
        [relation addObject:pageScoreElement.pageScoreID];
    }];
*/
    [testScore saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFRelation *relation = [testScore relationforKey:@"pageScoreIDs"];
            [thisTestScoreElement.pageScores enumerateObjectsUsingBlock:^(PageScoreElement *pageScoreElement, NSUInteger idx, BOOL *stop) {
                [relation addObject:pageScoreElement.pageScoreObjectID];
            }];
            [testScore saveEventually];
        }
    }];
    self.testScoreObjectID = nil;
}
/*-(void)uploadPageScoreStart:(PageScoreElement*)thisPageScoreElement{
    PFObject *pageScore = [PFObject objectWithClassName:@"zdPageScores"];
    thisPageScoreElement.pageScoreID = pageScore;
}*/
-(void)uploadPageScoreEnd:(PageScoreElement*)thisPageScoreElement{
    // early exit if there is not a valid assessmentInstance
    if (self.assessmentInstance == nil) return;

    //PFObject *pageScore = thisPageScoreElement.pageScoreID;
    PFObject *pageScore = [PFObject objectWithClassName:@"zdPageScores"];
    
    thisPageScoreElement.pageScoreObjectID = pageScore;
    
    if (self.battery.name) pageScore[@"battery"] = self.battery.name;
    if (self.batteryScoreObjectID) pageScore[@"batteryScoreID"] = self.batteryScoreObjectID;
    if (self.assessmentInstance.firstName) pageScore[@"subjectFirstName"] = self.assessmentInstance.firstName;
    if (self.assessmentInstance.dOB) pageScore[@"subjectDOB"] = self.assessmentInstance.dOB;
    pageScore[@"subjectAge"] = [NSNumber numberWithFloat:self.assessmentInstance.age];
    if (thisPageScoreElement.thisTest.name) pageScore[@"test"] = thisPageScoreElement.thisTest.name;
    if (thisPageScoreElement.thisPage.name) pageScore[@"page"] = thisPageScoreElement.thisPage.name;
    if (self.testScoreObjectID) pageScore[@"testScoreID"] = self.testScoreObjectID;
    
    
    pageScore[@"answerIsCorrect"] = [NSNumber numberWithBool:thisPageScoreElement.answerIsCorrect];
    if (thisPageScoreElement.answer) {
        pageScore[@"answer"] = thisPageScoreElement.answer.name;
    }
    
    NSMutableArray *answersName = [[NSMutableArray alloc]initWithCapacity:thisPageScoreElement.answers.count];
    [thisPageScoreElement.answers enumerateObjectsUsingBlock:^(SCElement *element, NSUInteger idx, BOOL *stop) {
        [answersName addObject:element.name];
    }];
    if (answersName.count) {
        pageScore[@"answers"] = answersName;
    }
    
    double time = round(100 * thisPageScoreElement.timeForPage) / 100;
    pageScore[@"time"] = [NSNumber numberWithDouble:time];

    [pageScore saveEventually];
}

@end
