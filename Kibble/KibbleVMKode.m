//
//  KibbleVMKode.m
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KibbleVMKode.h"
#import "KibbleVM.h"

@interface KibbleVMKode ()
@property (nonatomic, strong) NSString* kibbleKodeAsScript;
@end


@implementation KibbleVMKode
@synthesize result;

-(id)result{
    JSValue *thisResult;
    
    if (self.kibbleKodeAsScript) {
        
        thisResult = [[KibbleVM sharedVM] evaluateScript:self.kibbleKodeAsScript];
        
    }
     
    return (thisResult);
}

-(void)setKibbleKodeAsNativeVMScript:(NSString*)thisScript{
    self.kibbleKodeAsScript = thisScript;
}

@end
