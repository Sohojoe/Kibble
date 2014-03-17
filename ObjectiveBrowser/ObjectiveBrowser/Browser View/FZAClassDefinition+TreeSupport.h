//
//  FZAClassDefinition+TreeSupport.h
//  ObjectiveBrowser
//
//  Created by Graham Lee on 07/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import "FZAClassDefinition.h"

@interface FZAClassDefinition (TreeSupport)

- (NSInteger)countOfChildren;
- (id)childAtIndex: (NSInteger)index;
- (BOOL)isExpandable;

@end
