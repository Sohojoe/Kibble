//
//  FZAPropertyDefinition+TreeSupport.m
//  ObjectiveBrowser
//
//  Created by Graham Lee on 07/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import "FZAPropertyDefinition+TreeSupport.h"

@implementation FZAPropertyDefinition (TreeSupport)

- (NSString *)accessString {
    if (self.access = FZAPropertyAccessReadOnly) {
        return @"read-only";
    } else {
        return @"read-write";
    }
}

- (NSInteger)countOfChildren {
    return 0;
}

- (id)childAtIndex:(NSInteger)index {
    return nil;
}

- (BOOL)isExpandable {
    return NO;
}

- (NSString *)name {
    return [NSString stringWithFormat: @"%@ (%@ property)", self.title, [self accessString]];
}

@end
