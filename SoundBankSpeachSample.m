//
//  SoundBankSpeachSample.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 12/9/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import "SoundBankSpeachSample.h"
#import "SoundBank.h"

@implementation SoundBankSpeachSample

-(SoundBankSpeachSample*)initWithName:(NSString*)thisName textToSpeach:(NSString*) thisTextToSpeach forThisTest:(id)thisTest;
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.name = thisName;
        self.textToSpeach = thisTextToSpeach;
        
        [SoundBank registerObject:self forThisTest:thisTest];
    }
    return self;
}

@end
