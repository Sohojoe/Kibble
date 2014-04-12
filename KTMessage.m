//
//  KTMessage.m
//  Kibble
//
//  Created by Joe on 4/2/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KTMessage.h"
#import "KTObject.h"
@interface KTMessage ()
@property (nonatomic, strong) NSMutableArray *paramMessageAtIdx;
@property (nonatomic, strong) NSMutableArray *paramSyntaxAtIdx;
@end

@implementation KTMessage
/*
+(instancetype)messageWith:(NSString*)aMessageName with:(NSMutableArray*)theParams{
    KTMessage *o = [KTMessage new];
    
    if (o) {
        o.messageName = aMessageName;
        o.params = theParams;
        
        if (o.params == nil) {
            o.params = [NSMutableArray new];
        }
    }
    return o;
}
*/
-(instancetype)init{
    KTMessage *o = [KTMessage alloc];
    
    if (o) {
        if (o.paramMessageAtIdx == nil) {
            o.paramMessageAtIdx = [NSMutableArray new];
        }
        if (o.paramSyntaxAtIdx == nil) {
            o.paramSyntaxAtIdx = [NSMutableArray new];
        }
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


-(id)sendMessage{
    id returns = [self sendMessageTo:self.targetObject.theObject];
    return returns;
}
-(id)sendMessageTo:(id)recievingObject{
    self.returnedObject = recievingObject;
    

    SEL theSelector = NSSelectorFromString(self.messageName);

    //Class theClass = NSClassFromString(self.name);
    
    if([recievingObject respondsToSelector:theSelector]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[recievingObject methodSignatureForSelector:theSelector]];
        [inv setSelector:theSelector];
        [inv setTarget:recievingObject];
        
        __block BOOL messageIsIncomplete = NO;
        [self.paramMessageAtIdx enumerateObjectsUsingBlock:^(id param, NSUInteger idx, BOOL *stop) {

            NSUInteger trueIndex = 2 + idx; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
            
            // handle objects as parms
            if ([param isKindOfClass:[KTObject class]]) {
                // param is an object
                KTObject *paramObject = param;
                id __autoreleasing paramResult = paramObject.theObject;
                [inv setArgument:&paramResult atIndex:trueIndex];
                return;
            }
            
            else if ([param isKindOfClass:[KTMessage class]]) {
            
                // abort if this param has not being defined
                KTMessage *paramMessage = param;
                if (paramMessage.isBlankMessage) {
                    messageIsIncomplete = YES;
                    *stop = YES;
                    return;
                }
                
                id __autoreleasing paramResult = nil;
                paramResult = [self sendMessage];
                [inv setArgument:&paramResult atIndex:trueIndex];
                return;
            }

        }];
        if (messageIsIncomplete) {
            // exit
            return ([KTMessage blankMessage]);
        }
        [inv invoke];
        
        NSString *methodReturnType = [NSString stringWithUTF8String:inv.methodSignature.methodReturnType];
        NSLog(@"%@", methodReturnType);
        
        
        CFTypeRef cfResult;
        [inv getReturnValue:&cfResult];
        if (cfResult) {
            CFRetain(cfResult);
            self.returnedObject = (__bridge_transfer id)cfResult;
        }
  
/*        CFTypeRef cfResult;
        id result;
        [inv getReturnValue:&cfResult];
        [inv getReturnValue:&result];
        if (result) {
            if ([result isKindOfClass:[NSObject class]]) {
                CFRetain(cfResult);
                self.returnedObject = (__bridge_transfer id)cfResult;
            }
        }
*/
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
    aParam = [self.paramSyntaxAtIdx objectAtIndex:idx];
    return aParam;
}
/// if param = KTMessage, returns message. If param = KTObject returns theObject
-(id)paramResultOrObjectAtIdx:(NSUInteger)idx{
    id param =[self.paramMessageAtIdx objectAtIndex:idx];
    if ([param isKindOfClass:[KTMessage class]]) {
        KTMessage *paramMessage = param;
        id result = [paramMessage sendMessage];
        return result;
    } else if ([param isKindOfClass:[KTObject class]]) {
        KTObject *paramObject = param;
        id result = paramObject.theObject;
        return result;
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
    if (idx+1 < self.paramMessageAtIdx.count) {
        [self.paramSyntaxAtIdx replaceObjectAtIndex:idx withObject:aParam];
        [self.paramMessageAtIdx replaceObjectAtIndex:idx withObject:[KTMessage blankMessage]];
    } else {
        [self.paramSyntaxAtIdx addObject:aParam];
        [self.paramMessageAtIdx addObject:[KTMessage blankMessage]];
    }
}

-(NSString*)description{return self.messageName;}
-(NSString*)debugDescription{return [NSString stringWithFormat:@"%@ params=%@", self.messageName, self.paramMessageAtIdx];}
@end
