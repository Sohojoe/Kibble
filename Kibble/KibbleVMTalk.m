//
//  KibbleVMTalk.m
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KibbleVMTalk.h"
#import "KibbleVM.h"


@implementation KTParam @end

@interface KibbleVMTalk ()
@property (nonatomic, strong) NSString *kibbleKodeScript;
@end

@implementation KibbleVMTalk
@synthesize kibbleKode, paramaters, orderedParamatersKeys;



// Lazy inits
-(NSString*)kibbleKode{
    if (kibbleKode == nil) {
        kibbleKode = @"";
    }
    return kibbleKode;
}
-(NSMutableDictionary*)paramaters{
    if (paramaters == nil) {
        paramaters = [[NSMutableDictionary alloc]init];
    }
    return paramaters;
}
-(NSMutableArray*)orderedParamatersKeys{
    if (orderedParamatersKeys == nil) {
        orderedParamatersKeys = [[NSMutableArray alloc]init];
    }
    return orderedParamatersKeys;
}

// call the function with data
-(id)resultForTheseParamaters:(NSArray*)params{
    id thisResult = nil;
    thisResult = [[KibbleVM sharedVM] callFunctionForObject:self WithArguments:params];
    return (thisResult);
}





// set up the talk / function
-(void)addTalkToParamater:(id)thisParamater paramaterName:(NSString*)thisParamateName andDescription:(NSString*)thisDescription{
    
    KTParam *newParam = [[KTParam alloc]init];
    newParam.paramater = thisParamater;
    newParam.name = thisParamateName;
    newParam.description = thisDescription;
    
    [self.paramaters setObject:newParam forKey:thisParamater];
    [self.orderedParamatersKeys addObject:newParam];
}


-(void)addKibbleKode:(id)thisKibbleKode{
    self.kibbleKode = thisKibbleKode;
    [[KibbleVM sharedVM] setVMScriptForObject:self];
}

@end
