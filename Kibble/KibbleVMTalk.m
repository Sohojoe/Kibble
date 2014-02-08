//
//  KibbleVMTalk.m
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KibbleVMTalk.h"
#import "KibbleVM.h"

@interface KTParam : NSObject
@property (nonatomic, strong) NSString *paramater;
@property (nonatomic) SupportedDataTypes supportedData;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@end
@implementation KTParam @end

@interface KibbleVMTalk ()
@property (nonatomic, strong) NSString *kibbleKodeScript;
@property (nonatomic, strong) JSValue *function;
@property (nonatomic, strong) NSString *script;
@property (nonatomic, strong) NSMutableDictionary* paramaters;
@property (nonatomic, strong) NSMutableArray *orderedParamatersKeys;
@property (nonatomic, strong) NSString* kibbleKode;
@end

@implementation KibbleVMTalk
@synthesize kibbleKode, paramaters, orderedParamatersKeys, totalPhases;



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
    
    // Version #1 - just calls the function with the params - this doesnt evaluate the paramaters
    //thisResult = [self callFunctionWithArguments:params];
    
    // Version #2 - builds a script and evaluates it - this will evaluate each paramater
    //thisResult = [self parseParamsAndEvaluateAsScript]; // note not writen yet
    
    // version #3 - parses the params and evaluate each parm that is not a NSNumber
    NSMutableArray *evaluatedParams = [[NSMutableArray alloc]initWithCapacity:params.count];
    [params enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            // is NSnumber, just copy
            [evaluatedParams addObject:obj];
        } else {
            id evaluatedObj = nil;
            if ([obj isKindOfClass:[NSString class]]) {
                evaluatedObj = [[KibbleVM sharedVM] evaluateScript:obj];
            } else {
                evaluatedObj = [[KibbleVM sharedVM] evaluateScript:[NSString stringWithFormat:@"%@", obj]];
            }
            [evaluatedParams addObject:evaluatedObj];
        }
    }];
    thisResult = [self callFunctionWithArguments:evaluatedParams];
    
    
    return (thisResult);
}

// set up the talk / function
-(void)addParamaterPhase:(id)thisParamater supportedDataType:(SupportedDataTypes)supportedData paramaterName:(NSString*)thisParamateName andDescription:(NSString*)thisDescription{
    
    KTParam *newParam = [[KTParam alloc]init];
    newParam.paramater = thisParamater;
    newParam.supportedData = supportedData;
    newParam.name = thisParamateName;
    newParam.description = thisDescription;
    
    [self.paramaters setObject:newParam forKey:thisParamater];
    [self.orderedParamatersKeys addObject:thisParamater];
}


-(void)setKibbleKode:(id)thisKibbleKode{
    kibbleKode = thisKibbleKode;
    [self setVMScriptForObject];
}


// -- Phases
-(NSUInteger)totalPhases{
    NSUInteger phaseCount;
    phaseCount = self.paramaters.count;
    return phaseCount;
}
-(void)forThisPhase:(NSUInteger)thisPhase findDetails:(void (^)(id paramater, SupportedDataTypes supportedData, NSString* name, NSString* description))detailsBlock{
    
    NSString *key = [self.orderedParamatersKeys objectAtIndex:thisPhase];
    
    KTParam *phaseParam = [self.paramaters objectForKey:key];
    
    if (detailsBlock) {
        NSString *ourName;
        if (thisPhase == 0) {
            ourName = self.name;
            if (phaseParam.name) {
                ourName = [NSString stringWithFormat:@"%@ %@", ourName, phaseParam.name];
            }
        } else {
            ourName = phaseParam.name;
        }
        detailsBlock(phaseParam.paramater, phaseParam.supportedData, ourName, phaseParam.description);
    }
}
-(void)enumeratePhases:(void (^)(id paramater, SupportedDataTypes supportedData, NSString* name, NSString* description))detailsBlock{
    NSUInteger phase = 0;
    
    while (phase < self.paramaters.count) {
        [self forThisPhase:phase findDetails:detailsBlock];
        phase++;
    }
}
-(BOOL)isNextPhaseForTheseParamaters:(NSArray*)params {
    BOOL result = NO;

    NSUInteger phase = params.count;
    if (phase < self.paramaters.count) {
        result = YES;
    }
    return result;
}
-(void)ifNextPhaseForTheseParamaters:(NSArray*)params findDetails:(void (^)(id paramater, SupportedDataTypes supportedData, NSString* name, NSString* description))detailsBlock;{
    
    NSUInteger phase = params.count;
    
    if (phase < self.paramaters.count) {
        [self forThisPhase:phase findDetails:detailsBlock];
    }
}
-(BOOL)isDataTypeSupported:(id)thisDate forNextPhaseForTheseParamaters:(NSArray*)params{
    return YES;
    
}
-(BOOL)isDataTypeSupported:(id)thisDate forThisPhase:(NSUInteger)thisPhase{
    
    return YES;
    
}

//---------------------------------------------------------------------------------
// --
// -- VM specific implementation


-(NSString*)buildScriptForVM{
    
    __block NSString* script = @"";
    
    // add the variabe
    //script = [NSString stringWithFormat:@"%@var %@", script, thisObject.name];
    script = [NSString stringWithFormat:@"%@%@", script, self.name];
    
    // add the = function
    script = [NSString stringWithFormat:@"%@ = function", script];
    
    // add the paramaters
    script = [NSString stringWithFormat:@"%@(", script];
    
    [self.paramaters enumerateKeysAndObjectsUsingBlock:^(id key, KTParam* thisParamater, BOOL *stop) {
        if ([[script substringFromIndex:script.length-1] isEqualToString:@"("] == NO) {
            // when not the first param, add commer
            script = [NSString stringWithFormat:@"%@,", script];
        }
        script = [NSString stringWithFormat:@"%@%@", script, thisParamater.paramater];
    }];
    script = [NSString stringWithFormat:@"%@)", script];
    
    // add the function body
    script = [NSString stringWithFormat:@"%@ {return ", script];
    script = [NSString stringWithFormat:@"%@%@", script, self.kibbleKode];
    script = [NSString stringWithFormat:@"%@ ;}", script];
    
    return script;
}

-(void)setVMScriptForObject{
    
    JSValue *debug;
    
    // define this var TEMP
    debug = [[KibbleVM sharedVM] evaluateScript:[NSString stringWithFormat:@"var %@", self.name]];
    NSLog(@"debug = %@", debug);
    
    
    // set the script
    self.script = [self buildScriptForVM];
    debug = [[KibbleVM sharedVM]  evaluateScript:self.script];
    NSLog(@"debug = %@", debug);
    
    // get a reference to the function
    self.function = [[KibbleVM sharedVM] referenceForObjectName:self.name];
    
    //[context evaluateScript:@"var square = function(x) {return x*x;}"];
    //JSValue *squareFunction = context[@"square"];
    
    //    [context evaluateScript:@"var square = function(x) {return x*x;}"];
    return;
}
-(id)callFunctionWithArguments:(NSArray*)theseArguments{
    JSValue *outcome;
    
    outcome = [self.function callWithArguments:theseArguments];
    return outcome;
}


@end
