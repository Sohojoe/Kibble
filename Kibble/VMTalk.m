//
//  VMTalk.m
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "VMTalk.h"
#import "KibbleVM.h"


@interface VMTalk ()
@property (nonatomic, strong) NSString *kibbleKodeScript;
@property (nonatomic, strong) JSValue *function;
@property (nonatomic, strong) NSString *script;
@property (nonatomic, strong) NSMutableDictionary* paramaters;
@property (nonatomic, strong) NSMutableArray *orderedParamatersKeys;
@property (nonatomic, strong) NSString* kibbleKode;
@end

@implementation VMTalk
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

-(NSString*)description{
    __block NSString* str = @"";
    
    str = self.name;
    [self.orderedParamatersKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        VMTalkPhase *thisPhase = [self.paramaters objectForKey:key];
        str = [NSString stringWithFormat:@"%@ %@", str, thisPhase.description];
    }];
    
    return str;
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
-(void)addPhaseWith:(VMTalkPhase *)thisTalkPhaseDate{
    
    NSString * key = thisTalkPhaseDate.paramater;
    
    [self.paramaters setObject:thisTalkPhaseDate forKey:key];
    [self.orderedParamatersKeys addObject:key];
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
-(void)forThisPhase:(NSUInteger)phaseIndex findPhaseData:(void (^)(VMTalkPhase *))detailsBlock{
    NSString *key = [self.orderedParamatersKeys objectAtIndex:phaseIndex];
    if (detailsBlock) {
        detailsBlock([self.paramaters objectForKey:key]);
    }
}
-(void)enumeratePhases:(void (^)(VMTalkPhase *))detailsBlock{
    NSUInteger phase = 0;
    
    while (phase < self.paramaters.count) {
        [self forThisPhase:phase findPhaseData:detailsBlock];
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
-(void)ifNextPhaseForTheseParamaters:(NSArray *)params findPhaseData:(void (^)(VMTalkPhase *))detailsBlock{
    NSUInteger phase = params.count;
    
    if (phase < self.paramaters.count) {
        [self forThisPhase:phase findPhaseData:detailsBlock];
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
    
    [self.paramaters enumerateKeysAndObjectsUsingBlock:^(id key, VMTalkPhase* thisParamater, BOOL *stop) {
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
