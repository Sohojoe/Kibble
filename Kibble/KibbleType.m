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
@property (nonatomic) unsigned long countOfUniqueInstances;
@property (nonatomic, strong) NSMapTable *kibbleInstances;
@end


@implementation KibbleType
@synthesize kibbleInstanceClass, kibbleInstances;
+(id)type{
    static id shared = nil;
    
    if (shared==nil) {
        // first Time Init
        //shared = [[super allocWithZone:NULL] init];
        shared = [[KBDatabase aDatabase] kibbleTypeElseLazyInitForKey:[NSString stringWithFormat:@"%@", [super class]]];
        
    }
    return shared;
}
-(Class)kibbleInstanceClass{return ([Kibble class]);}
-(Kibble*)createNewKibbleInstanceWithName:(NSString*)thisName{
    Kibble *newKibbleInstance = nil;
    
    newKibbleInstance = [[self.kibbleInstanceClass alloc]initWithKibbleType:self];
    newKibbleInstance.name = thisName;
    newKibbleInstance.description = thisName;
    
    // add to list of KibbleInstances
    [self.kibbleInstances setObject:newKibbleInstance forKey:thisName];
    
    self.countOfUniqueInstances++;
    
    return newKibbleInstance;
}
-(Kibble*)createNewKibbleInstance{
    NSString *uniqueName = [NSString stringWithFormat:@"%@%lul", [self.kibbleInstanceClass class], self.countOfUniqueInstances];
    return ([self createNewKibbleInstanceWithName:uniqueName]);
};
-(Kibble*)createNewKibbleInstanceContaining:(id)thisContent{
    NSString *uniqueName = [NSString stringWithFormat:@"%@%lul", [self.kibbleInstanceClass class], self.countOfUniqueInstances];
    return ([self createNewKibbleInstanceWithName:uniqueName containing:thisContent]);
}
-(Kibble*)createNewKibbleInstanceWithName:(NSString*)thisName containing:(id)thisContent{
    Kibble *newKibbleInstance = [self createNewKibbleInstanceWithName:thisName];
    newKibbleInstance.content = thisContent;
    newKibbleInstance.description = [NSString stringWithFormat:@"%@", thisContent];
    return newKibbleInstance;
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
    self.description = thisDescription;
    
    return self;
}

@end
