//
//  Kibble.m
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "Kibble.h"
#import "KBDatabase.h"
#import "MathHelper.h"

@interface Kibble ()
@end

@implementation Kibble
@synthesize kibbleDescription, content;

+(id)type{return ([KibbleType type]);};

+(id)createNewKibbleInstanceWithName:(NSString*)thisName{
    id newKibbleInstance = nil;
    
    newKibbleInstance = [[self alloc]initWithKibbleType:[self type]];
    Kibble *k = newKibbleInstance;
    k.name = thisName;
    
    // add to list of KibbleInstances
    [[self type] addKibbleInstance:newKibbleInstance];
    
    
    return newKibbleInstance;
}
+(Kibble*)createNewKibbleInstance{
    return ([self createNewKibbleInstanceWithName:[[self type] getUniqueName]]);
};
+(Kibble*)createNewKibbleInstanceContaining:(id)thisContent{
    return ([self createNewKibbleInstanceWithName:[[self type] getUniqueName] containing:thisContent]);
}
+(Kibble*)createNewKibbleInstanceWithName:(NSString*)thisName containing:(id)thisContent{
    Kibble *newKibbleInstance = [self createNewKibbleInstanceWithName:thisName];
    newKibbleInstance.content = thisContent;
    return newKibbleInstance;
}





-(id)initWithKibbleType:(KibbleType *)thisKibbleType{
    self = [super init];
    if (self) {
        // init code
    }
    
    return self;
}

-(void)setContent:(id)thisContent{
    NSDecimalNumber *contentAsADecNum = [MathHelper decNumFromObject:thisContent];
    if (contentAsADecNum) {
        content = contentAsADecNum;
    } else {
        content = thisContent;
    }
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
