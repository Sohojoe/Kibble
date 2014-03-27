//
//  KTInterface.h
//  Kibble
//
//  Created by Joe on 3/26/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTClassRnD.h"

@interface KTMethodNode : NSObject
@property (strong, nonatomic) NSMutableOrderedSet *methods;
@property (strong, nonatomic) KTMethodParam *methodParm;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *appendedName;
@property (nonatomic) NSUInteger subNodesCount;
@property (nonatomic) BOOL nodeCanTerminate;
@property (nonatomic) NSMutableDictionary *nodeTreeChildren;
@end


@interface KTInterface : NSObject
+(void)addFoundationFromDisk:(NSString*)foundationName;
+(instancetype)interface;
/// initerMode only looks for initer nodes and sets up the function
@property (nonatomic) BOOL initerMode;

//-(void)listFoundations:(void(^)(NSOrderedSet* foundations))block;
@property (strong, nonatomic) KTFoundation *foundation;
@property (strong, nonatomic, readonly) NSOrderedSet *foundations;

//-(void)listClasses:(void(^)(NSOrderedSet* classes))block;
@property (strong, nonatomic) KTClass *curClass;
@property (strong, nonatomic, readonly) NSOrderedSet *classes;

//-(void)listMethodNodes:(void(^)(NSOrderedSet* methodNodes))block;
@property (strong, nonatomic, readonly) NSOrderedSet *nodes;

@property (strong, nonatomic) KTMethodNode* curNode;

@end
