//
//  FZAClassGroup+TreeSupport.m
//  ObjectiveBrowser
//
//  Created by Graham Lee on 07/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import "FZAClassGroup+TreeSupport.h"

@implementation FZAClassGroup (TreeSupport)

- (NSInteger)countOfChildren {
    return [self countOfClasses];
}

- (id)childAtIndex:(NSInteger)index {
//    return nil;
    return [self objectInClassesAtIndex: index];
}

- (BOOL)isExpandable {
    return [self countOfClasses] != 0;
}

@end
