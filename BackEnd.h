//
//  BackEnd.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/13/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackEnd : NSObject
+(BackEnd *)sharedBackEnd;
-(void)oneTimeSetup:(NSDictionary *)launchOptions;


+(void)analyticsRecordScreen:(NSString*)screenName;
+(void)analyticsRecordAction:(NSString*)action;
+(void)analyticsRecordAction:(NSString*)action withDictionary:(NSDictionary*)actionDetail;
+(void)analyticsRecordAction:(NSString*)action withDetail:(NSString*)detail;

// connected helper fictions
-(BOOL)isCloudOnline;
//-(BOOL)isUserLinkedToFacebook;
-(BOOL)isUserLoggedIn;
-(BOOL)isInternetConnectionValid;
-(BOOL)ifNoInternetConnectionThenThrowError:(void (^)(void))blockOnErrorCompletion;
+(NSString*)findPlatform;
@end
