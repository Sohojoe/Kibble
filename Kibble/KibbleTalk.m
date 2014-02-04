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
@end

@implementation KibbleTalk
@synthesize result, paramaterObjects, paramaterDescription, paramatersKeys;


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

-(id)result{
    id thisResult = nil;
    
    NSDecimalNumber *x = [self.paramaterObjects objectForKey:[self.paramatersKeys objectAtIndex:0]];
    
    
    thisResult = [x decimalNumberByMultiplyingBy:x];
    
    return thisResult;
}

-(NSString*)kibbleDescription{
    __block NSString *description = @"";
    
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



@end
