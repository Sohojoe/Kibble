//
//  FZASourceDefinition+TreeSupport.m
//  ObjectiveBrowser
//
//  Created by Graham Lee on 12/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FZASourceDefinition+TreeSupport.h"

@implementation FZASourceDefinition (TreeSupport)

- (NSInteger)countOfChildren {
    return 0;
}

- (id)childAtIndex: (NSInteger)index {
    return nil;
}

- (BOOL)isExpandable {
    return NO;
}

- (NSString *)name {
    return self.definition;
}

@end
