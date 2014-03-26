//
//  KTClassInterface.h
//  Kibble
//
//  Created by Joe on 3/26/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTClassRnD.h"

@interface KTMethodNode : NSObject
@property (strong, nonatomic) KTMethod *method;
@property (strong, nonatomic) KTMethodParam *methodParm;
@property (nonatomic) NSUInteger subNodesCount;
-(void)listSubNodes:(void(^)(NSSet* subNodes))block;
@property (nonatomic) BOOL nodeCanTerminate;
@end


@interface KTClassInterface : NSObject
+(void)addFoundationFromDisk:(NSString*)foundationName;
+(instancetype)interface;

-(void)listFoundations:(void(^)(NSSet* foundations))block;
@property (strong, nonatomic) KTFoundation *aFoundation;

-(void)listClasses:(void(^)(NSSet* classes))block;
@property (strong, nonatomic) KTClass *aClass;

-(void)listMethodNodes:(void(^)(NSSet* methodNodes))block;

-(void)setNode:(KTMethodNode*) node;

@end
