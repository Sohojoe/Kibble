//
//  FZASourceDefinition+TreeSupport.h
//  ObjectiveBrowser
//
//  Created by Graham Lee on 12/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FZASourceDefinition.h"

@interface FZASourceDefinition (TreeSupport)

- (NSInteger)countOfChildren;
- (id)childAtIndex: (NSInteger)index;
- (BOOL)isExpandable;
- (NSString *)name;

@end
