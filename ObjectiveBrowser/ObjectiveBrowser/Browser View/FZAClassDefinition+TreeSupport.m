//
//  FZAClassDefinition+TreeSupport.m
//  ObjectiveBrowser
//
//  Created by Graham Lee on 07/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import "FZAClassDefinition+TreeSupport.h"

@implementation FZAClassDefinition (TreeSupport)

- (NSInteger)countOfChildren {
    return [self countOfMethods] + [self countOfProperties];
}

- (id)childAtIndex:(NSInteger)index {
    if (index < [self countOfMethods]) {
        return [self methodAtIndex: index];
    } else {
        return [self propertyAtIndex: index - [self countOfMethods]];
    }
}

- (BOOL)isExpandable {
    return [self countOfChildren] != 0;
}

@end
