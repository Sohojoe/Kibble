//
//  ScreenerBattery.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/2/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import "SCBattery.h"

@implementation SCBattery
-(SCBattery*)initWithName:(NSString*) thisName
             textToSpeach:(id)thisTextToSpeach
                    tests:(NSArray*)theseTests{
    self.name = thisName;
    self.textToSpeach = thisTextToSpeach;
    self.tests = theseTests;
    
    return self;
}


static NSString *requestedBatteryName;
+(void)setRequestedBatteryName:(NSString*)thisBatteryName{
    requestedBatteryName = thisBatteryName;
}
+(NSString*)requestedBatteryName{
    return (requestedBatteryName);
}
@end
