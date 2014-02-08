//
//  KibbleVMCoreObject.m
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KibbleVMObject.h"

@implementation KibbleVMObject
@synthesize name, description;
+(id)createNewKibbleInstanceWithName:(NSString*)thisName{
    id newKibbleInstance = nil;
    
    //newKibbleInstance = [[self alloc]initWithKibbleType:[self type]];
    newKibbleInstance = [[self alloc]init];
    KibbleVMObject *k = newKibbleInstance;
    k.name = thisName;
    
    // add to list of KibbleInstances
    //[[self type] addKibbleInstance:newKibbleInstance];
    
    //[[JS activeJS] addClass:k];
    
    return newKibbleInstance;
}
+(id)createNewKibbleInstance{
    //return ([self createNewKibbleInstanceWithName:[[self type] getUniqueName]]);
    return ([self createNewKibbleInstanceWithName:@"NO_NAME"]);
};
+(id)createNewKibbleInstanceContaining:(id)thisContent{
    return ([self createNewKibbleInstanceWithName:@"NO_NAME" containing:thisContent]);
}
+(id)createNewKibbleInstanceWithName:(NSString*)thisName containing:(id)thisContent{
    KibbleVMObject *newKibbleInstance = [self createNewKibbleInstanceWithName:thisName];
    //newKibbleInstance.content = thisContent;
    return newKibbleInstance;
}
@end
