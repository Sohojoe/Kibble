//
//  Local.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 1/18/14.
//  Copyright (c) 2014 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Local : NSObject

+(Local*)sharedLocal;

#define LocalString(key) \
[[Local sharedLocal] localizedStringForKey:(key) fallback:@""]
#define LocalStringFallback(key, fallbackStr) \
[[Local sharedLocal] localizedStringForKey:(key) fallback:fallbackStr]
- (NSString *)localizedStringForKey:(NSString *)key fallback:(NSString *)fallback;

@end
