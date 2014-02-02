//
//  SCTest.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/2/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCPage.h"
#import "SCDatabaseObjectProtocol.h"

@interface SCTest : NSObject <SCDatabaseObjectProtocol>
@property (strong, nonatomic)NSString *name;
@property (nonatomic, strong)NSString *textToSpeach;
@property (strong, nonatomic)NSArray *pages;
@property (nonatomic)BOOL compareAnswerWithCorrectTarget;


@property (nonatomic, readonly)BOOL isAPreviewTest;
// if this is a preview test, it will find the non preview conterpart, else will return this test
@property (nonatomic, readonly, strong)SCTest *nonPreviewCounterpartTest;

-(SCTest*)initWithName:(NSString*) thisName
          textToSpeach:(id)thisTextToSpeach
               pages:(NSArray*)thesePages;

@end
