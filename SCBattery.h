//
//  ScreenerBattery.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/2/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCTest.h"
#import "SCDatabaseObjectProtocol.h"

@interface SCBattery : NSObject <SCDatabaseObjectProtocol>
@property (strong, nonatomic)NSString *name;
@property (nonatomic, strong)NSString *textToSpeach;
@property (strong, nonatomic)NSArray *tests;


-(SCBattery*)initWithName:(NSString*) thisName
             textToSpeach:(id)thisTextToSpeach
                    tests:(NSArray*)theseTests;

+(void)setRequestedBatteryName:(NSString*)thisBatteryName;
+(NSString*)requestedBatteryName;

@end
