//
//  SoundBankSpeachSample.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 12/9/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundBankDataProtocol.h"

@interface SoundBankSpeachSample : NSObject <SoundBankDataProtocol>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *textToSpeach;
-(SoundBankSpeachSample*)initWithName:(NSString*)thisName textToSpeach:(NSString*) thisTextToSpeach forThisTest:(id)thisTest;

@end
