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



/// \brief a chunk of a KTMethod. Chunked at each paramater so the initial name section is a chunk (with or without a paramaeter), then each subsequent name section and param is a chunk
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
-(KTType*)returnType;
@end

@class KTObject;

@interface KTInterface : NSObject
+(void)addFoundationFromDisk:(NSString*)foundationName;
+(instancetype)interface;
+(instancetype)interfaceFromObject:(KTObject*)anObject;
+(instancetype)interfaceForClassNamed:(NSString*)aClassName;
+(instancetype)interfaceForCType:(NSValue*)aValue ofType:(KTType*)aType;

@property (strong, nonatomic) KTFoundation *foundation;
@property (strong, nonatomic, readonly) NSOrderedSet *foundations;

@property (strong, nonatomic) KTObject *targetObject;
@property (strong, nonatomic, readonly) NSOrderedSet *classes;



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

///will completed editing, set and return this object. assumes a NSNumber for cTypes and converts it to the ctype
-(void)completeUsingObject:(id)anObject;

//TO DELETE
//-(void)setIndex:(NSUInteger)idx withObject:(id)anObject ofClass:(Class) aClass;

/// calls walks through and call first a chunk and then its param (i.e. aChunk:aParam aChunk:aParam ...)
-(void)enumerateChunks:(void(^)(KTMethodChunk *aChunk, NSUInteger idx)) chunkBlock andParams:(void(^)(KTMethodParam *aParm, KTMethodChunk *aChunk, NSUInteger idx)) paramBlock;
@property (nonatomic, readonly) BOOL messageSyntaxIsValidMessage;
@property (nonatomic, readonly) BOOL messageHasMoreChunks;
@property (nonatomic, readonly) BOOL messageAllParamsAreValid;
@property (nonatomic, strong) KTMessage *theMessage;
@property (nonatomic, strong) void(^callWithCompletedMessageOrObject)(id aMessageOrObject);
-(void)setParamAtIdx:(NSUInteger)idx withMessageOrObject:(id)aMessageOrObject;
/// only sends the message if we are ready to do so
-(KTObject*)ifReadySendMessage;
@end
