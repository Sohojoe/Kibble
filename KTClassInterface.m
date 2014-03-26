//
//  KTClassInterface.m
//  Kibble
//
//  Created by Joe on 3/26/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KTClassInterface.h"

@implementation KTMethodNode
//@property (strong, nonatomic) KTMethod *method;
//@property (strong, nonatomic) KTMethodParam *methodParm;
//@property (nonatomic) NSUInteger subNodesCount;
-(void)listSubNodes:(void(^)(NSSet* subNodes))block{
    
}
//@property (nonatomic) BOOL nodeCanTerminate;
@end


@implementation KTClassInterface
static NSMutableSet *foundations;
+(void)addFoundationFromDisk:(NSString*)foundationName{
    if (foundations == nil) {
        foundations = [NSMutableSet new];
    }
    [foundations addObject:[KTFoundation foundationFromDisk:foundationName]];
}
+(instancetype)interface{
    KTClassInterface *o = [KTClassInterface new];
    return o;
}

-(void)listFoundations:(void(^)(NSSet* foundations))block{
    if (block) {
        NSSet *fs = [NSSet setWithSet:foundations];
        block (fs);
    }
}
//@property (strong, nonatomic) KTFoundation *aFoundation;

-(void)listClasses:(void(^)(NSSet* classes))block{
    
}
//@property (strong, nonatomic) KTClass *aClass;

-(void)listMethodNodes:(void(^)(NSSet* methodNodes))block{
    
}

-(void)setNode:(KTMethodNode*) node{
    
}


@end
