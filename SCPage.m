//
//  SCPage.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/2/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import "SCPage.h"

@implementation SCPage

-(SCPage*)initWithName:(NSString*) thisName
          textToSpeach:(id)thisTextToSpeach
        promptVoice:(id)thisPromptVoice
             prompt:(SCElement*)thisPrompt
            targets:(NSArray*)thisTargets{
    
    
    self.name = thisName;
    self.textToSpeach = thisTextToSpeach;
    self.prompt = thisPromptVoice;
    self.prompt = thisPrompt;
    self.targets = thisTargets;
    
    return (self);
}

@synthesize isADemo, isAPractice, isAPracticeOrDemo;


-(BOOL) isADemo{
    return ([self doesNameContain:@"Demo"]);
}
-(BOOL) isAPractice{
    return ([self doesNameContain:@"Practice"]);
}
-(BOOL) isAPracticeOrDemo{
    BOOL result;
    result = [self isADemo];
    result |= [self isAPractice];
    return (result);
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
