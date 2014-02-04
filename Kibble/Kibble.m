//
//  Kibble.m
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "Kibble.h"
#import "KBDatabase.h"


@interface Kibble ()
@end

@implementation Kibble
@synthesize kibbleDescription;

-(id)initWithKibbleType:(KibbleType *)thisKibbleType{
    self = [super init];
    if (self) {
        // init code
    }
    
    return self;
}

-(NSString*)kibbleDescription{
    __block NSString *description = @"";
    
    // add the name
    description = [NSString stringWithFormat:@"%@:", self.name];

    // display the content
    if ([self.content isKindOfClass:[NSDictionary class]]) {
        // display dictionary
        NSDictionary * dict = self.content;
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            description = [NSString stringWithFormat:@"%@ %@:%@", description,key, obj];
        }];
    } else if ([self.content isKindOfClass:[NSArray class]]) {
        // display array
        NSArray *array = self.content;
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            description = [NSString stringWithFormat:@"%@ %@", description,obj];
        }];
    } else {
        // display just the content
        description = [NSString stringWithFormat:@"%@ %@", description, self.content];
    }
    
    return description;
}




@end
