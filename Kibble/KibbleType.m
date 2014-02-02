//
//  KibbleType.m
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KibbleType.h"

@implementation KibbleType

-(KibbleType*)initWithName:(NSString*)thisName parent:(NSString*)thisParent description:(NSString*)thisDescription{
    self = [super init];
    self.name = thisName;
    self.parent = thisParent;
    self.description = thisDescription;
    
    return self;
}
@end
