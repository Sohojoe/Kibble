//
//  SCPage.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/2/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCElement.h"
#import "SCDatabaseObjectProtocol.h"

@interface SCPage : NSObject <SCDatabaseObjectProtocol>
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *textToSpeach;
@property (nonatomic, strong)id promptVoice;
@property (nonatomic, strong)SCElement *prompt;
@property (nonatomic, strong)NSArray *targets;
@property (nonatomic) uint correctTarget;

-(SCPage*)initWithName:(NSString*) thisName
          textToSpeach:(id)thisTextToSpeach
        promptVoice:(id)thisPromptVoice
             prompt:(SCElement*)thisPrompt
            targets:(NSArray*)thisTargets;


@property (nonatomic)BOOL isAPracticeOrDemo;
@property (nonatomic)BOOL isADemo;
@property (nonatomic)BOOL isAPractice;
-(BOOL)doesNameContain:(NSString*)subString;


@end
