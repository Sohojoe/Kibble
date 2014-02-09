//
//  JSRnD.m
//  Kibble
//
//  Created by Joe on 2/6/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "JSRnD.h"

@implementation JSRnD
- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %ld", self.name, (long)self.number];
}
@end
