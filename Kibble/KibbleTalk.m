//
//  KibbleTalk.m
//  Kibble
//
//  Created by Joe on 2/4/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KibbleTalk.h"
#import "MathHelper.h"

@interface KibbleTalk ()
@property (nonatomic, strong) NSMutableDictionary* paramaterObjects;
@property (nonatomic, strong) NSMutableDictionary* paramaterDescription;
@property (nonatomic, strong) NSMutableArray *paramatersKeys;
@property (nonatomic, strong) NSMutableArray *kibbleKode;
@end

@implementation KibbleTalk
@synthesize result, paramaterObjects, paramaterDescription, paramatersKeys, kibbleKode;


-(NSMutableDictionary*)paramaterObjects{
    if (paramaterObjects == nil){
        paramaterObjects = [[NSMutableDictionary alloc]init];
    }
    return paramaterObjects;
}
-(NSMutableDictionary*)paramaterDescription{
    if (paramaterDescription == nil){
        paramaterDescription = [[NSMutableDictionary alloc]init];
    }
    return paramaterDescription;
}
-(NSMutableArray*)paramatersKeys{
    if (paramatersKeys == nil){
        paramatersKeys = [[NSMutableArray alloc]init];
    }
    return paramatersKeys;
}
-(NSMutableArray*)kibbleKode{
    if (kibbleKode == nil){
        kibbleKode = [[NSMutableArray alloc]init];
    }
    return kibbleKode;
}


-(void)addKibbleTalkParamater:(id)thisParamater withSyntax:(NSString*)thisSyntax andDescription:(NSString*)thisDescription{

    // error
        // syntax already exists
        // no paramater
    
    // ensure number params are dec numbers
    NSDecimalNumber *decNumParam = [MathHelper decNumFromObject:thisParamater];
    if (decNumParam) {
        thisParamater = decNumParam;
    }
    
    if (thisSyntax == nil || thisSyntax.length == 0) {
        thisSyntax = [NSString stringWithFormat:@"param%lu",(unsigned long)self.paramaterObjects.count];
    }
    if (thisDescription == nil || thisDescription.length == 0) {
        thisDescription = [NSString stringWithFormat:@"param #%lu",(unsigned long)self.paramaterObjects.count];
    }
    
    [self.paramatersKeys addObject:thisSyntax];
    [self.paramaterObjects setObject:thisParamater forKey:thisSyntax];
    [self.paramaterDescription setObject:thisDescription forKey:thisSyntax];
}

-(void)addKibbleKode:(id)thisKibbleKode{
    // exit if null
    if (thisKibbleKode == nil) {
        return;
    }
    
    // ensure number params are dec numbers
    NSDecimalNumber *decNumParam = [MathHelper decNumFromObject:thisKibbleKode];
    if (decNumParam) {
        thisKibbleKode = decNumParam;
    }
    [self.kibbleKode addObject:thisKibbleKode];
}

//----------------------------------------------------------------------------------------------------

-(NSString*)kibbleDescription{
    __block NSString *description = @"";
    
    if (self.paramatersKeys.count == 0) {
        // no keys, display a differnet way
        [self.kibbleKode enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            description = [NSString stringWithFormat:@"%@ %@", description, obj];
        }];
        // add result
        if (self.result) {
            description = [NSString stringWithFormat:@"%@ = %@", description, self.result];
        }
        
        return description;
        
    }
    
    // add the name
    description = [NSString stringWithFormat:@"%@:", self.name];
    
    // add params
    [self.paramatersKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        description = [NSString stringWithFormat:@"%@ %@:%@", description,key, [self.paramaterObjects objectForKey:key]];
    }];
    
    // add result
    if (self.result) {
        description = [NSString stringWithFormat:@"%@ = %@", description, self.result];
    }
    
    return description;
}

//----------------------------------------------------------------------------------------------------
-(id)result{
    id thisResult = nil;
    
    if ([self isBasicMath]) {
        thisResult = [self basicMath];
    }

    return thisResult;
}


//----------------------------------------------------------------------------------------------------
-(BOOL)isBasicMath{
    return (YES);
}
-(id)basicMath{
    id thisResult = nil;
    
    id instruction0 = [self.kibbleKode objectAtIndex:0];
    id instruction1 = [self.kibbleKode objectAtIndex:1];
    id instruction2 = [self.kibbleKode objectAtIndex:2];
    id paramX = [MathHelper decNumFromObject:instruction0];
    NSString *mathType = instruction1;
    id paramY = [MathHelper decNumFromObject:instruction2];
    if ([self.paramatersKeys indexOfObject:instruction0] != NSNotFound) {
        paramX = [self.paramaterObjects objectForKey:instruction0];
    }
    if ([self.paramatersKeys indexOfObject:instruction2] != NSNotFound) {
        paramY = [self.paramaterObjects objectForKey:instruction2];
    }
    
    
    SEL mathSelector = [self selectorForMathType:mathType];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    
    if ([self numParamsForMathType:mathType] == 1) {
        thisResult = [paramX performSelector:mathSelector withObject:paramX];
        
    } else if ([self numParamsForMathType:mathType] == 2) {
        thisResult = [paramX performSelector:mathSelector withObject:paramY];
    }
#pragma clang diagnostic pop
    
    return thisResult;
    
    
    
}
-(SEL)selectorForMathType:(NSString*)mathType{
    NSDictionary *table
    = @{
        @"*": NSStringFromSelector(@selector(decimalNumberByMultiplyingBy:)),
        @"+": NSStringFromSelector(@selector(decimalNumberByAdding:)),
        @"-": NSStringFromSelector(@selector(decimalNumberBySubtracting:)),
        @"/": NSStringFromSelector(@selector(decimalNumberByDividingBy:)),
        };
    
    SEL thisResult = NSSelectorFromString([table objectForKey:mathType]);
    return thisResult;
}
-(unsigned int)numParamsForMathType:(NSString*)mathType{
    NSDictionary *table
    = @{
        @"*": @2,
        @"+": @2,
        @"-": @2,
        @"/": @2,
        };
    
    NSNumber *num = [table objectForKey:mathType];
    unsigned int thisResult = [num unsignedIntValue];
    return thisResult;
}


@end
