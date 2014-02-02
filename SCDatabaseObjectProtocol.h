//
//  SCDatabaseObjectProtocol.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 12/10/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundBankDataProtocol.h"

@protocol SCDatabaseObjectProtocol <NSObject, SoundBankDataProtocol>
-(NSString*)name;
-(NSString*)textToSpeach;
@optional
-(id) image;
-(id) promptVoice;
-(id) prompt;
-(NSArray*) targets;
-(uint) correctTarget;
-(BOOL) compareAnswerWithCorrectTarget;
-(NSArray*) pages;
-(NSArray*) tests;
-(NSDictionary*) multipleSoundBank;
@end
