//
//  KibbleVM.m
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KibbleVM.h"
@import JavaScriptCore;

@interface KibbleVM ()
@property (nonatomic, strong)JSContext *context;

@end


@implementation KibbleVM

+(KibbleVM*)sharedVM{
    static KibbleVM *shared = nil;
    
    if (shared==nil) {
        // first Time Init
        shared = [[super allocWithZone:NULL] init];
        
        // init the JS machine
        shared.context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
        
    }
    return shared;
}

-(id)evaluateScript:(id)thisScript{
    JSValue *result = [self.context evaluateScript:thisScript];
    return result;
}

-(id)referenceForObjectName:(NSString*)thisName{
    JSValue *result = self.context[thisName];
    return result;
}


@end
