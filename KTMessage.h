//
//  KTMessage.h
//  Kibble
//
//  Created by Joe on 4/2/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KTMethodParam;
@class KTObject;
@class KTType;

@interface KTMessage : NSObject
@property (nonatomic, strong) NSString* messageName;
@property (nonatomic, strong) KTObject *targetObject;
@property (nonatomic, strong) KTObject *returnedObject;

//+(instancetype)messageWith:(NSString*)aMessageName with:(NSMutableArray*)theParams;
+blankMessage;
@property (nonatomic, readonly) BOOL isBlankMessage;

/// tells us if the message is OK to be sent
@property (nonatomic) BOOL isValidAndComplete;
-(KTObject*)sendMessageTo:(KTObject*)recievingObject;
-(KTObject*)sendMessage;

-(void)setReturnType:(KTType*)aType;
-(KTObject*)setReturnObjectValue:(id)anObject;

// params
-(void)setParamMessageAtIdx:(NSUInteger)idx withMessageOrObject:(id)aMessageOrObject;
-(id)paramMessageOrObjectAtIdx:(NSUInteger)idx;
-(KTMethodParam*)paramSyntaxAtIdx:(NSUInteger)idx;
-(id)paramMessageResultOrObjectAtIdx:(NSUInteger)idx;
@property (nonatomic, readonly) NSUInteger paramCount;

// init and setting up a param
-(void)deleteParamFromIdx:(NSUInteger)idx;
-(void)initParamAtIdx:(NSUInteger)idx withParam:(KTMethodParam*)aParam;

@end
