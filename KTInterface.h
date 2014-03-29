//
//  KTInterface.h
//  Kibble
//
//  Created by Joe on 3/26/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTClassRnD.h"

@interface KTMethodNode : NSObject <NSCopying>
@property (strong, nonatomic) NSMutableOrderedSet *methods;
//@property (strong, nonatomic) KTMethodParam *methodParm;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *appendedName;
//@property (nonatomic) NSUInteger subNodesCount;
@property (nonatomic) BOOL nodeCanTerminate;
//@property (nonatomic) BOOL nodeIsParamTerminator;
@property (nonatomic, strong) NSMutableDictionary *nodeTreeChildren;
@end

@interface KTMethodChunk : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *appendedName;
@property (nonatomic) BOOL requiresParam;
@property (nonatomic,strong) KTMethodParam *param;
@property (nonatomic, strong) NSMutableDictionary *brancesTo;
+(instancetype)chunkWith:(NSString*)aName apppended:(NSString*)aAppendedName requires:(BOOL)doesRequireParam;
-(void)completeWith:(KTMethod*)aMethod;
-(void)addChild:(KTMethodChunk *)aChunk;
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
@property (nonatomic, strong) KTMethodNode* curNode;
@property (nonatomic) NSUInteger paramIdx;
@property (nonatomic, strong) NSMutableOrderedSet *paramList;
@property (nonatomic, strong) NSMutableOrderedSet *paramContent;
@property (nonatomic, strong) KTMethod *method;
@property (nonatomic) BOOL needsParam;
-(void)setParamContentWith:(id)thisContent;

@property (strong, nonatomic, readonly) NSOrderedSet *chunks;
@property (nonatomic, strong) NSMutableOrderedSet *chunkList;
-(void)selectChunk:(KTMethodChunk*)aChunk;

@end
