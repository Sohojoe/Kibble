//
//  FZAAppDelegate.h
//  ObjectiveBrowser
//
//  Created by Graham Lee on 05/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FZAAppDelegate : NSObject <NSApplicationDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSOutlineView *outlineView;

@end
