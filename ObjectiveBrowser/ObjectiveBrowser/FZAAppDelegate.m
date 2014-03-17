//
//  FZAAppDelegate.m
//  ObjectiveBrowser
//
//  Created by Graham Lee on 05/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import "FZAAppDelegate.h"
#import "FZAClassParser.h"
#import "FZAMethodPrintingParserDelegate.h"
#import "FZAModelBuildingParserDelegate.h"
#import "FZAClassGroup.h"
#import "FZAClassGroup+TreeSupport.h"

@implementation FZAAppDelegate
{
    FZAClassParser *parser;
    FZAModelBuildingParserDelegate *modelBuilder;
    FZAClassGroup *classGroup;
    NSTimer *dataRefreshTimer;
    NSDate *lastRefreshed;
}

@synthesize window = _window;
@synthesize outlineView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    lastRefreshed = [NSDate date];
    classGroup = [[FZAClassGroup alloc] init];

    //classGroup.name = @"Kibble.dia";
    //parser = [[FZAClassParser alloc] initWithSourceFile: @"/Users/apple/Library/Developer/Xcode/DerivedData/Kibble-abkuskypdjlzuvgetbbrrihfnlgw/Build/Intermediates/Kibble.build/Debug-iphonesimulator/Kibble.build/Objects-normal/i386/Kibble.dia"];
//    classGroup.name = @"KBRapidTestViewController.m";
//    parser = [[FZAClassParser alloc] initWithSourceFile: @"/Users/apple/development/Kibble/KBRapidTestViewController.m"];

    //classGroup.name = @"FZAMethodPrintingParserDelegate.m";
    //parser = [[FZAClassParser alloc] initWithSourceFile: @"/Users/apple/development/ObjectiveBrowser/ObjectiveBrowser/Clang Controller/FZAMethodPrintingParserDelegate.m"];

    classGroup.name = @"Classes";
    parser = [[FZAClassParser alloc] initWithSourceFile: @"/Users/apple/development/Kibble/ObjectiveBrowser/FilesToIndex.m"];

    
    modelBuilder = [[FZAModelBuildingParserDelegate alloc] initWithClassGroup: classGroup];
    parser.delegate = modelBuilder;
    [parser parse];
    dataRefreshTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(refreshTimer:) userInfo: nil repeats: YES];
}

- (void)refreshTimer: (NSTimer *)timer {
    [self.outlineView reloadData];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return [item name];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return 1;
    }
    return [item countOfChildren];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        return classGroup;
    }
    return [item childAtIndex: index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (item == nil) {
        return YES;
    }
    return [item isExpandable];
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    NSInteger countOfLines = [[[item name] componentsSeparatedByString: @"\n"] count];
    return countOfLines * 17.0;
}

@end
