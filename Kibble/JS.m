//
//  JSWrapper.m
//  Kibble
//
//  Created by Joe on 2/6/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "JS.h"


@interface JS ()
@property (nonatomic, strong)JSContext *context;
@end


@implementation JS
@synthesize context;

+(JS*)activeJS{
    static JS *shared = nil;
    
    if (shared==nil) {
        // first Time Init
        shared = [[super allocWithZone:NULL] init];
        
        // init the JS machine
        shared.context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];

    }
    return shared;
}
+(JSContext *)vM{
    return [JS activeJS].context;
}


-(void)addClass:(id)thisClass{
    if ([thisClass conformsToProtocol:@protocol(JSConform)]) {
        JSprototype *protoClass = thisClass;
        // add class to vm
        JSValue *output = self.context[protoClass.name] = thisClass;
        NSLog(@"%@", output);
        
    }
}


@end
