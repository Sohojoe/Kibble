//
//  KibbleType.m
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KibbleType.h"
#import "KBDatabase.h"

@implementation KibbleType
+(id)type{
    static id shared = nil;
    
    if (shared==nil) {
        // first Time Init
        //shared = [[super allocWithZone:NULL] init];
        shared = [[KBDatabase aDatabase] kibbleTypeElseLazyInitForKey:[NSString stringWithFormat:@"%@", [super class]]];
        
    }
    return shared;
}
-(KibbleType*)initWithName:(NSString*)thisName parent:(NSString*)thisParent description:(NSString*)thisDescription{
    self = [[[super class] allocWithZone:NULL] init];
    self.name = thisName;
    self.parent = thisParent;
    self.description = thisDescription;
    
    return self;
}


@end
