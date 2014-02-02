//
//  Local.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 1/18/14.
//  Copyright (c) 2014 Vidya Gamer, LLC. All rights reserved.
//

#import "Local.h"

@interface Local ()
@end

@implementation Local


+(Local*)sharedLocal{
    static Local *shared = nil;
    
    if (shared==nil) {
        // first Time Init
        shared = [[super allocWithZone:NULL] init];
        
/*
        NSLog(@"%@", [[NSBundle mainBundle] localizations]);
        NSLog(@"%@", [[NSBundle mainBundle] localizedInfoDictionary]);
        
        NSLog(@"%@", [[NSBundle mainBundle]developmentLocalization ]);
        NSLog(@"%@", [[NSBundle mainBundle]preferredLocalizations]);
        
        NSLog(@"%@", [[NSBundle mainBundle] localizedStringForKey:(@"Hello World") value:nil table:nil]);
        NSLog(@"%@", [[NSBundle mainBundle] localizedStringForKey:(@"Hello World2") value:@"eh" table:nil]);
        NSLog(@"%@", LocalString(@"Hello World"));
        NSLog(@"%@", LocalString(@"Hello World2"));
        NSLog(@"%@", LocalStringFallback(@"Hello World", @"fallback string"));
        NSLog(@"%@", LocalStringFallback(@"Hello World2", @"fallback string"));
*/
        
    }
    return shared;
}

- (NSString *)localizedStringForKey:(NSString *)key fallback:(NSString *)fallback{
    NSString *str;
    
    str = [[NSBundle mainBundle] localizedStringForKey:key value:fallback table:nil];
    
    return (str);
}

-(NSString*)testString{
    NSString* result;
    result = NSLocalizedString(@"Hello World", @"a test string");
    
    result = [[NSBundle mainBundle] localizedStringForKey:(@"Hello World") value:@"" table:nil];

    
    return (result);
}


@end
