//
//  MathHelper.m
//  Kibble
//
//  Created by Joe on 2/4/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "MathHelper.h"

@implementation MathHelper

+(NSDecimalNumber*)decNumFromObject:(id)object{
    NSDecimalNumber* result = nil;
    
    NSArray *stringsToSkip = @[@"+", @"-", @"e", @"E"];
    
    if ([object isKindOfClass:[NSNumber class]]) {
        result = [NSDecimalNumber decimalNumberWithDecimal:[object decimalValue]];
    }else if ([object isKindOfClass:[NSString class]]) {
        if ([stringsToSkip containsObject:object]) {
            // dont do anything
        } else {
            result = [NSDecimalNumber decimalNumberWithString:object locale:[NSLocale currentLocale]];
            if (result == [NSDecimalNumber notANumber]) {
                result = nil;
            }
        }
    }
    
    return result;
}


@end
