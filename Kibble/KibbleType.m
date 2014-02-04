//
//  KibbleType.m
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KibbleType.h"
#import "KBDatabase.h"
#import "Kibble.h"

@interface KibbleType ()
@property (nonatomic, strong) NSMapTable *kibbleInstances;
@end


@implementation KibbleType
@synthesize kibbleInstanceClass, kibbleInstances;
+(id)type{
    static id shared = nil;
    
    if (shared==nil) {
        // first Time Init
        //shared = [[super allocWithZone:NULL] init];
        shared = [[KBDatabase aDatabase] kibbleTypeElseLazyInitForKey:[super class]];
        
    }
    return shared;
}
-(Class)kibbleInstanceClass{return ([Kibble class]);}
/* old code DELETE
-(Kibble*)createNewKibbleInstanceWithName:(NSString*)thisName{
    Kibble *newKibbleInstance = nil;
    
    newKibbleInstance = [[self.kibbleInstanceClass alloc]initWithKibbleType:self];
    newKibbleInstance.name = thisName;
    
    // add to list of KibbleInstances
    [self.kibbleInstances setObject:newKibbleInstance forKey:thisName];
    
    self.countOfUniqueInstances++;
    
    return newKibbleInstance;
}
-(Kibble*)createNewKibbleInstance{
    return ([self createNewKibbleInstanceWithName:[self uniqueName]]);
};
-(Kibble*)createNewKibbleInstanceContaining:(id)thisContent{
    return ([self createNewKibbleInstanceWithName:[self uniqueName] containing:thisContent]);
}
-(Kibble*)createNewKibbleInstanceWithName:(NSString*)thisName containing:(id)thisContent{
    Kibble *newKibbleInstance = [self createNewKibbleInstanceWithName:thisName];
    newKibbleInstance.content = thisContent;
    return newKibbleInstance;
}
-(NSString*)uniqueName{
    NSString *uniqueName = [NSString stringWithFormat:@"%@%lu", [self.kibbleInstanceClass class], self.countOfUniqueInstances];
    
    if (uniqueName.length >= 2) {
        uniqueName = [NSString stringWithFormat:@"%@%@" ,
                      [[uniqueName substringToIndex:1] lowercaseString],
                      [uniqueName substringFromIndex:1]];
    } if (uniqueName.length == 1) {
        uniqueName = [uniqueName lowercaseString];
    }
    return uniqueName;
}
 */ // old code - to cut
-(void)addKibbleInstance:(id)thisKibbleInstance{
    // add to list of KibbleInstances
    Kibble *k = thisKibbleInstance;
    [self.kibbleInstances setObject:thisKibbleInstance forKey:k.name];
    
    self.countOfUniqueInstances++;
}
-(NSString*)getUniqueName{
    NSString *uniqueName = [NSString stringWithFormat:@"%@%lu", [self.kibbleInstanceClass class], self.countOfUniqueInstances];
    
    if (uniqueName.length >= 2) {
        uniqueName = [NSString stringWithFormat:@"%@%@" ,
                      [[uniqueName substringToIndex:1] lowercaseString],
                      [uniqueName substringFromIndex:1]];
    } if (uniqueName.length == 1) {
        uniqueName = [uniqueName lowercaseString];
    }
    return uniqueName;
}
-(BOOL)isKibbleInstanceNameUnique:(id)thisKibbleInstance{
    Kibble *k = thisKibbleInstance;
    if ([self.kibbleInstances objectForKey:k.name]) {
        return NO;
    }
    return YES;
}


-(NSMapTable*)kibbleInstances{
    if (kibbleInstances == nil) {
        //lazy init
        kibbleInstances = [NSMapTable strongToStrongObjectsMapTable];
    }
    return (kibbleInstances);
}



-(KibbleType*)initWithName:(NSString*)thisName parent:(NSString*)thisParent description:(NSString*)thisDescription{
    self = [[[super class] allocWithZone:NULL] init];
    self.name = thisName;
    self.parent = thisParent;
    self.kibbleTypeDescription = thisDescription;
    
    return self;
}

@end
