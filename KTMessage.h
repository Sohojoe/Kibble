//
//  KTMessage.h
//  Kibble
//
//  Created by Joe on 4/2/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KTMethodParam;

@interface KTMessage : NSObject
@property (nonatomic, strong) NSString* messageName;
@property (nonatomic, weak) id targetObject;
@property (nonatomic, copy) id returnedObject;

//+(instancetype)messageWith:(NSString*)aMessageName with:(NSMutableArray*)theParams;
+blankMessage;
@property (nonatomic, readonly) BOOL isBlankMessage;
-(id)sendMessageTo:(id)recievingObject;
-(id)sendMessage;

// params
-(void)setParamMessageAtIdx:(NSUInteger)idx withMessageOrObject:(KTMessage*)aMessageOrObject;
-(KTMessage*)paramMessageOrObjectAtIdx:(NSUInteger)idx;
-(KTMethodParam*)paramSyntaxAtIdx:(NSUInteger)idx;
-(id)paramResultOrObjectAtIdx:(NSUInteger)idx;
@property (nonatomic, readonly) NSUInteger paramCount;

// init and setting up a param
-(void)deleteParamFromIdx:(NSUInteger)idx;
-(void)initParamAtIdx:(NSUInteger)idx withParam:(KTMethodParam*)aParam;

@end
