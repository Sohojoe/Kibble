//
//  KibbleVM.h
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//


// This is the abstraction class of the virtual machine;
// This is the class Kibbles use to interface with the VM


#import <Foundation/Foundation.h>
#import "KibbleVMInstance.h"
#import "KibbleVMType.h"
#import "KibbleVMObject.h"
#import "KibbleVMTalk.h"


@interface KibbleVM : NSObject

+(KibbleVM*)sharedVM;
-(id)evaluateScript:(id)thisScript;

-(void)setVMScriptForObject:(KibbleVMTalk*)thisObject;
-(id)callFunctionForObject:(KibbleVMTalk*)thisObject WithArguments:(NSArray*)theseArguments;

@end
