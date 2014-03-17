//
//  FZAMethodDefinition+TreeSupport.m
//  ObjectiveBrowser
//
//  Created by Graham Lee on 07/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import "FZAMethodDefinition+TreeSupport.h"

@implementation FZAMethodDefinition (TreeSupport)

- (BOOL)hasSource {
    return !(self.sourceCode == nil);
}

- (NSInteger)countOfChildren {
    return [self hasSource] ? 1 : 0;
}

- (BOOL)isExpandable {
    return [self hasSource];
}

- (id)childAtIndex:(NSInteger)index {
    return self.sourceCode;
}

- (NSString *)name {
    return self.objCNameStyle;
    switch (self.type) {
        case FZAMethodClass:
            return [@"+" stringByAppendingString: self.selector];
            break;
        case FZAMethodInstance:
            return [@"-" stringByAppendingString: self.selector];
            break;
        default:
            return [@"?" stringByAppendingString: self.selector];
            break;
    }
}

@end
