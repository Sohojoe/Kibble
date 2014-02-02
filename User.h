//
//  User.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 1/29/14.
//  Copyright (c) 2014 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

+(User*)activeUser;
@property (nonatomic, strong) NSString* emailAddress;


- (BOOL)isStringALegalEmailAddress:(NSString*)thisString;
@end
