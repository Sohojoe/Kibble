//
//  VMTalkPhase.m
//  Kibble
//
//  Created by Joe on 2/8/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "VMTalkPhase.h"
@interface VMTalkPhase ()
@property (nonatomic, strong) NSMutableArray* supportedDataTypes;
@end

@implementation VMTalkPhase
@synthesize supportedDataTypesAsClassArray, supportedDataTypes;
@synthesize paramater;
@synthesize name, description;

+(VMTalkPhase*)phaseWithParamater:(NSString*)thisParam{
    return [self phaseWithParamater:thisParam ofType:nil withName:nil withDescription:nil];
}
+(VMTalkPhase*)phaseWithParamater:(NSString*)thisParam ofType:(id)supportedType{
    return [self phaseWithParamater:thisParam ofType:supportedType withName:nil withDescription:nil];
}
+(VMTalkPhase*)phaseWithParamater:(NSString*)thisParam ofType:(id)supportedType withName:(NSString*)thisName{
    return [self phaseWithParamater:thisParam ofType:supportedType withName:thisName withDescription:nil];
}
+(VMTalkPhase*)phaseWithParamater:(NSString*)thisParam ofType:(id)supportedType withName:(NSString*)thisName withDescription:(NSString*)thisDescription{
    VMTalkPhase* newPhase = [[VMTalkPhase alloc]init];
    newPhase.paramater = thisParam;
    newPhase.name = thisName;
    newPhase.description = thisDescription;
    [newPhase setSupportedDataFrom:supportedType];
    return (newPhase);
}


-(NSMutableArray*)supportedDataTypes{
    if (supportedDataTypes == nil) {
        supportedDataTypes = [[NSMutableArray alloc] init];
    }
    return supportedDataTypes;
}
-(NSArray*)supportedDataTypesAsClassArray{
    return self.supportedDataTypes;
}

-(void)setSupportedDataFrom:(id)abstractObject{
    [self.supportedDataTypes removeAllObjects];
    [self addSupportedDataFrom:abstractObject];
}
-(void)addSupportedDataFrom:(id)abstractObject{
    if (abstractObject == nil) {
        // Exit
        return;
    } else if ([abstractObject isKindOfClass:[NSArray class]]) {
        NSArray *arrayOfAbstractObjects = abstractObject;
        [arrayOfAbstractObjects enumerateObjectsUsingBlock:^(id thisAbstractObject, NSUInteger idx, BOOL *stop) {
            [self addSupportedDataFrom:thisAbstractObject];
            
        }];
    } else {
        [self addSupportedDataTypeAsClass:[abstractObject class]];
    }
    
}

-(void)setSupportedDataTypeAsClass:(Class)supportedType{
    [self.supportedDataTypes removeAllObjects];
    [self.supportedDataTypes addObject:supportedType];
}
-(void)setSupportedDataAsTypeClassArray:(NSArray*)supportedTypes{
    [self.supportedDataTypes removeAllObjects];
    [self.supportedDataTypes addObjectsFromArray:supportedTypes];
}
-(void)addSupportedDataTypeAsClass:(Class)supportedType{
    [self.supportedDataTypes addObject:supportedType];
}
-(void)addSupportedDataTypeAsClassArray:(NSArray*)supportedTypes{
    [self.supportedDataTypes addObjectsFromArray:supportedTypes];
}
-(void)enumerateSupportDataTypesAsClass:(void (^) (Class thisDatatypeAsClass))block{
    [self.supportedDataTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Class thisDatatypeAsClass = obj;
        if (block) block(thisDatatypeAsClass);
    }];
}
-(BOOL)doesSupportDataType:(Class)dataTypeAsClass{

    // if no types are specified, then all types are supported
    if (self.supportedDataTypes == nil) {
        return YES;
    }
    
    BOOL result = NO;
    result = [self.supportedDataTypes containsObject:dataTypeAsClass];
    return result;
}
-(BOOL)doesSupportDataTypes:(NSArray*)dataTypesAsClassArray{

    // if no types are specified, then all types are supported
    if (self.supportedDataTypes == nil) {
        return YES;
    }
    
    __block BOOL result = NO;
    [dataTypesAsClassArray enumerateObjectsUsingBlock:^(Class dataTypeAsClass, NSUInteger idx, BOOL *stop) {
        result |= [self doesSupportDataType:dataTypeAsClass];
    }];
    return result;
}

/*
 typedef enum
 {
 kObject         = -1,
 kNumber         = 1 << 0,   // = 1
 kBOOL           = 1 << 1,   // = 2
 kString         = 1 << 2,   // = 4
 kData           = 1 << 3,   // = 8
 kBlock          = 1 << 4,   // = 16
 kArray          = 1 << 5,   // = 32
 kDictionary     = 1 << 6,   // = 64
 } SupportedDataTypes;
*/

@end
