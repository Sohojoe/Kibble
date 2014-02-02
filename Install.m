//
//  Install.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 12/13/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import "Install.h"
#import "Parse.framework/Headers/Parse.h"
#import "BackEnd.h"

@interface Install ()
@property (nonatomic) NSTimeInterval timeOfLastRefreshDataFromServer;
@end

@implementation Install

+(Install*)sharedInstall{
    static Install *shared = nil;
    
    if (shared==nil) {
        // first Time Init
        shared = [[super allocWithZone:NULL] init];
    }
    return shared;
}

-(void)registerDefaults:(NSMutableDictionary*) defaults{
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

-(void)checkIfTimeThenRefreshDataFromServerSuccessBlock:(void (^)(BOOL success))completionBlock{
    if(![PFUser currentUser]) {
        // early exit if we have no online account
        if (completionBlock) completionBlock(NO);
        return;
    }
    
    // if time
    NSTimeInterval timeSinceLastRefreshDataFromServer = [NSDate timeIntervalSinceReferenceDate] - self.timeOfLastRefreshDataFromServer;
    NSTimeInterval anHour = 60*60;
    if (timeSinceLastRefreshDataFromServer >= (anHour *4)) {
        [self refreshDataFromServer:completionBlock];
    }
}

-(void)refreshDataFromServer:(void (^)(BOOL success)) completionBlock{
    static BOOL isAlreadyRunning = NO;
    
    BOOL isInternetOffline = ![[BackEnd sharedBackEnd] isInternetConnectionValid];
    
    // early exit if not cloud, is already running or is offline
    if(![PFUser currentUser] || isAlreadyRunning || isInternetOffline) {
        // early exit if we have no online account
        if (completionBlock) completionBlock(NO);
        return;
    }
    isAlreadyRunning = YES;
    self.timeOfLastRefreshDataFromServer = [NSDate timeIntervalSinceReferenceDate];
    // refresh the user
    [[PFUser currentUser] refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
/*example code
        // update furtestRead
        NSString* furthestChapterKey = [NSString stringWithFormat:@"%@_furthestChapter", self.activeBook.bookSKU];
        int serverFurthestChapter = [[[PFUser currentUser] objectForKey:furthestChapterKey] intValue];
        if (serverFurthestChapter > self.furthestChapter) {
            // update local
            self.furthestChapter = serverFurthestChapter;
        } else if (self.furthestChapter > serverFurthestChapter) {
            // update server
            [[PFUser currentUser] setObject:[NSNumber numberWithInt:self.furthestChapter] forKey:furthestChapterKey];
            //[[PFUser currentUser]saveEventually];
            [User parseTrackSave:[PFUser currentUser] debug:@"refreshDataFromServer"];
        }
*///example code

    }];
}


//--------------------------------------------------------------------------------------
// Install variables
-(id)getForKey:(NSString*)key{
    id result = nil;
    NSUserDefaults* userDefaults =[NSUserDefaults standardUserDefaults];
    result = [userDefaults objectForKey:key];
    return (result);
}
-(void)store:(id)obj forKey:(NSString*)key{
    NSUserDefaults* userDefaults =[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:obj forKey:key];
    [userDefaults synchronize];
    
}
/*example code

-(int)readingSpeed{
    NSUserDefaults* userDefaults =[NSUserDefaults standardUserDefaults];
    return([userDefaults integerForKey:@"readingSpeed"]);
}

-(void)setReadingSpeed:(int)newSpeed{
    NSUserDefaults* userDefaults =[NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:newSpeed forKey:@"readingSpeed"];
    [userDefaults synchronize];
    
    readingSpeed = newSpeed;
}
*///example code

/* how to code this
1. make each saved object part of install
2. have classes that need to sit on top of install,
 a) RegesiterDefaults (optional)
 b) per object code
 
 
 
*/

@end
