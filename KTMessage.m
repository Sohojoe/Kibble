//
//  KTMessage.m
//  Kibble
//
//  Created by Joe on 4/2/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KTMessage.h"

@implementation KTMessage
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
-(instancetype)init{
    KTMessage *o = [KTMessage alloc];
    
    if (o) {
        if (o.params == nil) {
            o.params = [NSMutableArray new];
        }
    }
    return o;
}
-(id)sendMessage{
    id returns = [self sendMessageTo:self.recievingObject];
    return returns;
}
-(id)sendMessageTo:(id)recievingObject{
    self.returnedObject = nil;
    //returns = @"Tuesday at tea time";
    //return returns;
    SEL theSelector = NSSelectorFromString(self.messageName);

    //Class theClass = NSClassFromString(self.name);
    
    if([recievingObject respondsToSelector:theSelector]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[recievingObject methodSignatureForSelector:theSelector]];
        [inv setSelector:theSelector];
        [inv setTarget:recievingObject];
        
        [self.params enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSUInteger trueIndex = 2 + idx; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
            [inv setArgument:&(obj) atIndex:trueIndex];
        }];
        
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
-(NSString*)description{return self.messageName;}
-(NSString*)debugDescription{return [NSString stringWithFormat:@"%@ params=%@", self.messageName, self.params];}
@end
