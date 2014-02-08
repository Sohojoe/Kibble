//
//  KibbleVMKode.m
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "VMKode.h"
#import "KibbleVM.h"

@interface VMKode ()
@property (nonatomic, strong) NSString* kibbleKodeAsScript;
@end


@implementation VMKode
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
