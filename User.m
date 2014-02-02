//
//  User.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 1/29/14.
//  Copyright (c) 2014 Vidya Gamer, LLC. All rights reserved.
//

#import "User.h"
#import "Install.h"

@implementation User
@synthesize emailAddress;

+(User*)activeUser{
    static User *shared = nil;
    
    if (shared==nil) {
        // first Time Init
        shared = [[super allocWithZone:NULL] init];
    }
    return shared;
}

-(NSString*)emailAddress{
    if (emailAddress == nil) {
        emailAddress = [[Install sharedInstall] getForKey:@"activeUserEmailAddress"];
    }
    return emailAddress;
}
-(void)setEmailAddress:(NSString *)thisEmailAddress{
    emailAddress = thisEmailAddress;
    if ([self isStringALegalEmailAddress:thisEmailAddress]){
        [[Install sharedInstall] store:thisEmailAddress forKey:@"activeUserEmailAddress"];
    }
}

- (BOOL)isStringALegalEmailAddress:(NSString*)thisString
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:thisString];
}

@end
