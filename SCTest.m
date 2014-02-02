//
//  SCTest.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/2/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import "SCTest.h"
#import "SCDatabase.h"

@implementation SCTest
@synthesize isAPreviewTest, nonPreviewCounterpartTest;

-(SCTest*)initWithName:(NSString *)thisName
          textToSpeach:(id)thisTextToSpeach
                 pages:(NSArray *)thesePages{
    self.name = thisName;
    self.textToSpeach = thisTextToSpeach;
    self.pages = thesePages;
    
    return self;
}

-(BOOL) isAPreviewTest{
    return ([self doesNameContain:@"Preview"]);
}
// if this is a preview test, it will find the non preview conterpart, else will return this test
-(SCTest *)nonPreviewCounterpartTest{
    SCTest *result = self;
    if (self.isAPreviewTest) {
        NSString *key = [self.name stringByReplacingOccurrencesOfString:@"Preview" withString:@""];
        result = [[SCDatabase activeDatabase] testForKey:key];
    }
    return result;
}

-(BOOL)doesNameContain:(NSString*)subString{
    BOOL result;
    NSString *lowerName = [self.name lowercaseString];
    NSString *lowerSubString = [subString lowercaseString];
    if ([lowerName rangeOfString:lowerSubString].location == NSNotFound) {
        //NSLog(@"string does not contain bla");
        result = NO;
    } else {
        //NSLog(@"string contains bla!");
        result = YES;
    }
    return result;
}
@end
