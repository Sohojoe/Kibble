//
//  KTInterface.h
//  Kibble
//
//  Created by Joe on 3/26/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTClassRnD.h"
#import "KTMessage.h"

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


/// \brief a chunk of a KTMethod. Chunked at each paramater
@interface KTMethodChunk : NSObject
/// \brief name of this chunk
@property (strong, nonatomic) NSString *name;
/// \brief full name including parent chunks
@property (strong, nonatomic) NSString *appendedName;
/// \brief chunk requires a param
@property (nonatomic) BOOL requiresParam;
@property (nonatomic,strong) KTMethodParam *param;
@property (nonatomic, strong) NSMutableDictionary *brancesTo;
+(instancetype)chunkWith:(NSString*)aName apppended:(NSString*)aAppendedName;
+(instancetype)chunkWith:(NSString*)aName apppended:(NSString*)aAppendedName param:(KTMethodParam*)aParam;
-(void)completeWith:(KTMethod*)aMethod;
-(void)addChild:(KTMethodChunk *)aChunk;
@end


@interface KTInterface : NSObject
+(void)addFoundationFromDisk:(NSString*)foundationName;
+(instancetype)interface;
+(instancetype)interfaceForClassNamed:(NSString*)aClassName;
/// initerMode only looks for initer nodes and sets up the function
@property (nonatomic) BOOL initerMode;

//-(void)listFoundations:(void(^)(NSOrderedSet* foundations))block;
@property (strong, nonatomic) KTFoundation *foundation;
@property (strong, nonatomic, readonly) NSOrderedSet *foundations;

//-(void)listClasses:(void(^)(NSOrderedSet* classes))block;
@property (strong, nonatomic) KTClass *curClass;
@property (strong, nonatomic, readonly) NSOrderedSet *classes;

//-(void)listMethodNodes:(void(^)(NSOrderedSet* methodNodes))block;
//@property (strong, nonatomic, readonly) NSOrderedSet *nodes;
//@property (nonatomic, strong) KTMethodNode* curNode;
//@property (nonatomic) NSUInteger paramIdx;
//@property (nonatomic, strong) NSMutableOrderedSet *paramList;
//@property (nonatomic, strong) NSMutableOrderedSet *paramContent;
//@property (nonatomic, strong) KTMethod *method;
//@property (nonatomic) BOOL needsParam;
//-(void)setParamContentWith:(id)thisContent;

//
/**
 * \brief Call blocks with chunks at this idx.
 *
 * This function visits all the potential chunks at this idx
 *
 * \param idx the index to inspect
 *
 * \param chunksBlock called for each valid chunk.
 *
 * \param doneBlock called if this chunk can terminate as a complete function.
 *
 */
-(void)enumerateChunksAtIndex:(NSUInteger)idx chunks:(void (^)(KTMethodChunk *aChunk)) chunksBlock done:(void (^)(KTMethod *aMethod)) doneBlock;

@property (strong, nonatomic, readonly) NSOrderedSet *chunks;

-(void)setChunkIdx:(NSUInteger)idx with:(KTMethodChunk*)aChunk;
-(void)setParamData:(NSUInteger)idx with:(id)aData;
/// calls walks through and call first a chunk and then its param (i.e. aChunk:aParam aChunk:aParam ...)
-(void)enumerateChunks:(void(^)(KTMethodChunk *aChunk, NSUInteger idx)) chunkBlock andParams:(void(^)(KTMethodParam *aParm, KTMethodChunk *aChunk, NSUInteger idx)) paramBlock;
@property (nonatomic) BOOL messageComplete;
@property (nonatomic) BOOL messageHasMoreChunks;
@property (nonatomic, strong) KTMessage *theMessage;
@property (nonatomic, strong) void(^callWithCompletedMessage)(KTMessage *aMessage);


@end
