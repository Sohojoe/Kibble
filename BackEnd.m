//
//  BackEnd.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/13/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import "BackEnd.h"
#import "Parse.framework/Headers/Parse.h"
//#import "Parse.framework/Headers/PFFacebookUtils.h"
#import "UIAlertViewBlock.h"
#import "Reachability.h"
@import QuartzCore;
@import MobileCoreServices;
@import CoreLocation;
@import CFNetwork;
@import CoreGraphics;
@import AudioToolbox;
@import Security;
#include <sys/types.h>
#include <sys/sysctl.h>

@interface BackEnd()
@end

@implementation BackEnd

+(BackEnd*)sharedBackEnd{
    static BackEnd *shared = nil;
    
    if (shared==nil) {
        // first Time Init
        shared = [[super allocWithZone:NULL] init];
    }
    return shared;
}

//#define VIDYA_USE_LIVE_SERVERS
-(void)oneTimeSetup:(NSDictionary *)launchOptions{
    // Yes = live servers
    // No = development servers
    NSString *parseApplicationId, *parseClientKey, *flurryKey, *testFlightKey, *apptentiveKey;
    
#ifdef VIDYA_USE_LIVE_SERVERS
    // live servers
    parseApplicationId = nil;
    parseClientKey = nil;
    flurryKey = nil;
    testFlightKey = nil;        // same key for dev and live (as they share the same bundle ID)
    apptentiveKey = nil;
#else
    // development servers
    parseApplicationId = @"1Z0evnIbK5DZ42vE9TUoNwlbpOD0Urj5jmqJn3pW";
    parseClientKey = @"li8AVWhIFTSr06WbR0rl4VSuudepLrYiBBadyPcf";
    flurryKey = nil; // Crowded Fiction Key
    testFlightKey = nil;
    // !!!: Use the next line only during beta
    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    apptentiveKey = nil;
#endif
    
    // init Parse
    [Parse setApplicationId:parseApplicationId
                  clientKey:parseClientKey];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    //[PFFacebookUtils initializeFacebook];
    [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:launchOptions[@"UIApplicationLaunchOptionsRemoteNotificationKey"]];
}

//-----------------------------------------
+(void)analyticsRecordScreen:(NSString*)screenName{
    
}
+(void)analyticsRecordAction:(NSString*)action{
    
}
+(void)analyticsRecordAction:(NSString*)action withDictionary:(NSDictionary*)actionDetail{
    
}
+(void)analyticsRecordAction:(NSString*)action withDetail:(NSString*)detail{
    
}

-(BOOL)isCloudOnline{return ((BOOL) [PFUser currentUser]);}
/*-(BOOL)isUserLinkedToFacebook{
    BOOL result = [PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
    return (result);
}
*/
-(BOOL)isUserLoggedIn{
    BOOL result = ([PFUser currentUser]) ? YES: NO;
    return (result);
}
-(BOOL)isInternetConnectionValid{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    return (internetStatus == NotReachable) ? NO : YES;
}
-(BOOL)ifNoInternetConnectionThenThrowError:(void (^)(void))blockOnErrorCompletion{
    if ([self isInternetConnectionValid]) {
        return NO;
    }
    UIAlertViewBlock *alert = [[UIAlertViewBlock alloc] initWithTitle:@"Internet Connection Error"
                                                              message:@"Oh no! It looks like you are disconnected from the Internet… That's so 1981.\n\nPlease take any necessary steps to reconnect to the internet.\n– Turn off Airplane Mode\n– Connect to a WiFi network\n– Turn on Cellular Data\n- Buy a Modem"
                                                           completion:^(BOOL cancelled, NSInteger buttonIndex)
                               {
                                   if(blockOnErrorCompletion) blockOnErrorCompletion();
                               }
                                                    cancelButtonTitle:@"Got It"
                                                    otherButtonTitles:nil];
    [alert show];
    
    return YES;
}
// helper to find the device
// get device

+(NSString*)findPlatform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    //NSString *platform = [NSString stringWithCString:machine];
    NSString *platform = [NSString stringWithFormat:@"%s", machine];
    
    free(machine);
    return platform;
}
@end
