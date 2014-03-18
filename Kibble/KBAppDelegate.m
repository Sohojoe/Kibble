//
//  KBAppDelegate.m
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KBAppDelegate.h"
#import "BackEnd.h"

// For SuperDB
//#import </Users/apple/development/Kibble/superdb/SuperDBCore/SuperDBCore/SuperDBCore.h>
#import <SuperDBCore/SuperDBCore/SuperDBCore.h>
@import CFNetwork;
@import CoreData;
@import Security;
@import UIKit;
@import Foundation;
@import CoreGraphics;

#import "RootViewController.h"
#import "iPadDetailViewController.h"



@import SystemConfiguration;
@import UIKit;
@import Foundation;

@implementation KBAppDelegate {
    SuperInterpreterService *_interpreterService;
}
@synthesize window = _window;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[BackEnd sharedBackEnd] oneTimeSetup:launchOptions];
    
    
    // For SuperDB
    _interpreterService = [SuperInterpreterService new];
	if ([_interpreterService startServer]) {
		[_interpreterService publishServiceWithCallback:^(id success, NSDictionary *errorDictionary) {
			if (errorDictionary) {
				NSLog(@"There was a problem starting the SuperDebugger service: %@", errorDictionary);
				return;
			}
			
			// The service is now on the network, ready to run interpreter events.
		}];
	}
	[_interpreterService setCurrentSelfPointerBlock:^id {
		// Return whatever you'd like to be pointed to by `self`.
		// This might be whatever your topmost view controller is
		// How you get it is up to you!
		// return _navigationController.topViewController;
		return self.window.rootViewController;
	}];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen]
                                                   bounds]];
    RootViewController *rootViewController = [[RootViewController alloc]
                                              initWithStyle:UITableViewStyleGrouped];
    UINavigationController *rootNavController =
    [[UINavigationController alloc]
     initWithRootViewController:rootViewController];
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==
        UIUserInterfaceIdiomPhone)
    {
        self.window.rootViewController = rootNavController;
    }
    else
    {
        iPadDetailViewController *detailViewController =
        [[iPadDetailViewController alloc]
         initWithStyle:UITableViewStyleGrouped];
        UINavigationController *detailNavController =
        [[UINavigationController alloc]
         initWithRootViewController:detailViewController];
        // Connect the master model to the detail model
        rootViewController.tableViewModel.detailViewController =
        detailViewController;
        UISplitViewController *splitViewController =
        [[UISplitViewController alloc] init];
        splitViewController.viewControllers =
        [NSArray arrayWithObjects:rootNavController,
         detailNavController, nil];
        self.window.rootViewController = splitViewController;
    }
    [self.window makeKeyAndVisible];
    
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
