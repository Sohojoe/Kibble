//
//  Install.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 12/13/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Install : NSObject
+(Install *)sharedInstall;
-(void)store:(id)obj forKey:(NSString*)key;
-(id)getForKey:(NSString*)key;
@end
