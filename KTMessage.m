//
//  KTMessage.m
//  Kibble
//
//  Created by Joe on 4/2/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KTMessage.h"
#import "KTObject.h"
#import "KTClassRnD.h"

@interface KTMessage ()
@property (nonatomic, strong) NSMutableArray *paramMessageAtIdx;
@property (nonatomic, strong) NSMutableArray *paramSyntaxAtIdx;
@property (nonatomic, strong) Class returnClass;
@property (nonatomic, strong) KTType *returnType;

@end

@implementation KTMessage

-(instancetype)init{
    KTMessage *o = [KTMessage alloc];
    
    if (o) {
        if (o.paramMessageAtIdx == nil) {
            o.paramMessageAtIdx = [NSMutableArray new];
        }
        if (o.paramSyntaxAtIdx == nil) {
            o.paramSyntaxAtIdx = [NSMutableArray new];
        }
        o.returnedObject = [KTObject objectFor:nil from:[NSNull class]];
    }
    return o;
}

static KTMessage *blank = nil;
+blankMessage{
    if (blank == nil) {
        blank = [KTMessage new];
        blank.messageName = @"blank";
    }
    return blank;
}
@synthesize isBlankMessage;
-(BOOL)isBlankMessage{
    if (self == [KTMessage blankMessage]) {
        return YES;
    } else {
        return NO;
    }
}


-(KTObject*)sendMessage{
    KTObject *returns = [self sendMessageTo:self.targetObject];
    return returns;
}
-(KTObject *)sendMessageTo:(KTObject*)recievingObject{
    [self setReturnObjectToNil];
    

    SEL theSelector = NSSelectorFromString(self.messageName);

    //Class theClass = NSClassFromString(self.name);
    
    if([recievingObject.theObject respondsToSelector:theSelector]) {
        
        NSMethodSignature * signature = [recievingObject.theObject methodSignatureForSelector:theSelector];
        
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:signature];
        [inv setSelector:theSelector];
        [inv setTarget:recievingObject.theObject];
        
        __block BOOL messageIsIncomplete = NO;
        [self.paramMessageAtIdx enumerateObjectsUsingBlock:^(id param, NSUInteger idx, BOOL *stop) {

            NSUInteger trueIndex = 2 + idx; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
            
            // handle objects as parms
            if ([param isKindOfClass:[KTObject class]]) {
                // param is an object
                KTObject *paramObject = param;
                if (paramObject.isCType) {
                    // is a c type
                    long long paramResult;
                    [paramObject.theValue getValue:&paramResult];
                    [inv setArgument:&paramResult atIndex:trueIndex];
                    return;
                    
                } else {
                    // is an object
                    id __autoreleasing paramResult = paramObject.theObject;
                    [inv setArgument:&paramResult atIndex:trueIndex];
                    return;
                }
            }
            
            else if ([param isKindOfClass:[KTMessage class]]) {
            
                // abort if this param has not being defined
                KTMessage *paramMessage = param;
                if (paramMessage.isBlankMessage || paramMessage.isValidAndComplete == NO) {
                    messageIsIncomplete = YES;
                    *stop = YES;
                    return;
                }
                
                KTObject *paramResultFull = [paramMessage sendMessage];
                id __autoreleasing paramResult = paramResultFull.theObject;
                [inv setArgument:&paramResult atIndex:trueIndex];
                return;
            }

        }];
        if (messageIsIncomplete) {
            // exit
            //self.returnedObject = [KTObject objectFor:[KTMessage blankMessage] from:self.returnedObject.theObjectClass];
            return self.returnedObject;
        }
        [inv invoke];
        
        
        NSValue    * ret_val  = nil;
        NSUInteger   ret_size = [signature methodReturnLength];
        
        if(  ret_size > 0 ) {
            
            void * ret_buffer = malloc( ret_size );
            
            [inv getReturnValue:ret_buffer];
            
            ret_val = [NSValue valueWithBytes:ret_buffer
                                     objCType:[signature methodReturnType]];
            
            free(ret_buffer);
        }
        if (strcmp([ret_val objCType], @encode(id) ) == 0) {
            //NSLog(@"%@",[ret_val pointerValue]);
            // it's a pointer
            if ([(id)ret_val.pointerValue isKindOfClass:[KTObject class]]) {
                self.returnedObject = (__bridge_transfer  KTObject *)(ret_val.pointerValue);
            } else {
                self.returnedObject = [KTObject objectFor:(__bridge_transfer  KTObject *)(ret_val.pointerValue) from:self.returnClass];
            }
        } else {
            self.returnedObject = [KTObject objectForValue:ret_val ofType:self.returnType];
        }
        NSLog(@"%@", [self.returnedObject description]);
    }
    
    return self.returnedObject;
}


// params
-(void)setParamMessageAtIdx:(NSUInteger)idx withMessageOrObject:(id)aMessageOrObject{
    if (aMessageOrObject == nil) {
        aMessageOrObject = [KTMessage blankMessage];
    }
    if (idx+1 <= self.paramMessageAtIdx.count) {
        [self.paramMessageAtIdx replaceObjectAtIndex:idx withObject:aMessageOrObject];
    } else {
        [self.paramMessageAtIdx addObject:aMessageOrObject];
        //[self.paramSyntaxAtIdx addObject:nil];
    }
}
/// returns the raw context of this idx (KTMessage or KTObject)
-(id)paramMessageOrObjectAtIdx:(NSUInteger)idx{
    id aParam = nil;
    aParam = [self.paramMessageAtIdx objectAtIndex:idx];
    return aParam;
}
-(KTMethodParam*)paramSyntaxAtIdx:(NSUInteger)idx{
    KTMethodParam* aParam = nil;
    if (idx < self.paramSyntaxAtIdx.count) {
        aParam = [self.paramSyntaxAtIdx objectAtIndex:idx];
    }
    return aParam;
}
/// if param = KTMessage, returns message. If param = returns KTObject
-(id)paramMessageResultOrObjectAtIdx:(NSUInteger)idx{
    id param =[self.paramMessageAtIdx objectAtIndex:idx];
    if ([param isKindOfClass:[KTMessage class]]) {
        KTMessage *paramMessage = param;
        KTObject *result = [paramMessage sendMessage];
        return result;
    } else if ([param isKindOfClass:[KTObject class]]) {
        KTObject *paramObject = param;
        return paramObject;
    }
    return param;
}

@synthesize paramCount;
-(NSUInteger)paramCount{
    return (self.paramMessageAtIdx.count);
}

// init and setting up a param
-(void)deleteParamFromIdx:(NSUInteger)idx{
    // check if we need to remove params
    while (self.paramMessageAtIdx.count > idx) {
        [self.paramSyntaxAtIdx  removeObjectAtIndex:self.paramMessageAtIdx.count-1];
        [self.paramMessageAtIdx removeObjectAtIndex:self.paramMessageAtIdx.count-1];
    }
}

-(void)initParamAtIdx:(NSUInteger)idx withParam:(KTMethodParam *)aParam{
    id messageOrObject = nil;
    if (aParam.paramType.isCType) {
        // is c type
        NSValue *aVal = [aParam.paramType nillValue];
        messageOrObject = [KTObject objectForValue:aVal ofType:aParam.paramType];
    } else {
        // is object
        messageOrObject = [KTMessage blankMessage];
    }
    
    if (idx+1 < self.paramMessageAtIdx.count) {
        [self.paramSyntaxAtIdx replaceObjectAtIndex:idx withObject:aParam];
        [self.paramMessageAtIdx replaceObjectAtIndex:idx withObject:    messageOrObject];
    } else {
        [self.paramSyntaxAtIdx addObject:aParam];
        [self.paramMessageAtIdx addObject:messageOrObject];
    }
}

-(void)setReturnType:(KTType*)aType{
    _returnType = aType;
    
    if (aType.isCType) {
        // return is a cType
        NSValue *aValus = [aType nillValue];
        KTObject *newReturnObject = [KTObject objectForValue:aValus ofType:aType];
        self.returnedObject = newReturnObject;
        self.returnClass = nil;
    } else {
        // return is a object
        NSString *returnClassName = aType.name;
        Class aClass = NSClassFromString(returnClassName);
        self.returnClass = aClass;
        KTObject *newReturnObject = [KTObject objectFor:nil from:self.returnClass];
        self.returnedObject = newReturnObject;
    }
}
-(KTObject*)setReturnObjectValue:(id)anObject{
    if (self.returnType.isCType) {
        // return is a cType
        if ([anObject isKindOfClass:[NSNumber class]]) {
            NSNumber *aNumber = anObject;
            NSValue *aValus = [self.returnType valueFromNumber:aNumber];
            KTObject *newReturnObject = [KTObject objectForValue:aValus ofType:self.returnType];
            self.returnedObject = newReturnObject;
        }
    } else {
        // return is a object
        self.returnedObject = [KTObject objectFor:anObject from:self.returnClass];
    }
    return self.returnedObject;
}

-(void)setReturnObjectToNil{
    if (self.returnType.isCType) {
        // return is a cType
        NSValue *aValus = [self.returnType nillValue];
        KTObject *newReturnObject = [KTObject objectForValue:aValus ofType:self.returnType];
        self.returnedObject = newReturnObject;
    } else {
        // return is a object
        self.returnedObject = [KTObject objectFor:nil from:self.returnClass];
    }
}

-(NSString*)description{return self.messageName;}
-(NSString*)debugDescription{return [NSString stringWithFormat:@"%@ params=%@", self.messageName, self.paramMessageAtIdx];}
@end
