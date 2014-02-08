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


-(NSString*)buildScriptForThisVM:(KibbleVMTalk*)thisObject{
    
    __block NSString* script = @"";
    
    // add the variabe
    //script = [NSString stringWithFormat:@"%@var %@", script, thisObject.name];
    script = [NSString stringWithFormat:@"%@%@", script, thisObject.name];
    
    // add the = function
    script = [NSString stringWithFormat:@"%@ = function", script];
    
    // add the paramaters
    script = [NSString stringWithFormat:@"%@(", script];
    
    [thisObject.paramaters enumerateKeysAndObjectsUsingBlock:^(id key, KTParam* thisParamater, BOOL *stop) {
        if ([[script substringFromIndex:script.length-1] isEqualToString:@"("] == NO) {
            // when not the first param, add commer
            script = [NSString stringWithFormat:@"%@,", script];
        }
        script = [NSString stringWithFormat:@"%@%@", script, thisParamater.paramater];
    }];
    script = [NSString stringWithFormat:@"%@)", script];
    
    // add the function body
    script = [NSString stringWithFormat:@"%@ {return ", script];
    script = [NSString stringWithFormat:@"%@%@", script, thisObject.kibbleKode];
    script = [NSString stringWithFormat:@"%@ ;}", script];
    
    return script;
}

-(void)setVMScriptForObject:(KibbleVMTalk*)thisObject{
    
    JSValue *debug;
    
    // define this var TEMP
    debug = [self.context evaluateScript:[NSString stringWithFormat:@"var %@", thisObject.name]];
    NSLog(@"debug = %@", debug);
    
    
    // set the script
    thisObject.script = [self buildScriptForThisVM:thisObject];
    debug = [self.context evaluateScript:thisObject.script];
    NSLog(@"debug = %@", debug);
    
    // get a reference to the function
    thisObject.function = self.context[thisObject.name];
    
    //[context evaluateScript:@"var square = function(x) {return x*x;}"];
    //JSValue *squareFunction = context[@"square"];

    //    [context evaluateScript:@"var square = function(x) {return x*x;}"];
    return;
}
-(id)callFunctionForObject:(KibbleVMTalk*)thisObject WithArguments:(NSArray*)theseArguments{
    JSValue *outcome;
    
    outcome = [thisObject.function callWithArguments:theseArguments];
    return outcome;
}

@end
