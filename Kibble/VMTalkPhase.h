//
//  VMTalkPhase.h
//  Kibble
//
//  Created by Joe on 2/8/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMObject.h"

@class VMTalkPhase;

@protocol VMTalkPhaseExport <VMObjectExport>
// enherits name from VMObject
// enherits description from VMObject
@property (nonatomic, strong) NSString *paramater;
@property (nonatomic, strong, readonly) NSArray* supportedDataTypesAsClassArray;

+(VMTalkPhase*)phaseWithParamater:(NSString*)thisParam;
+(VMTalkPhase*)phaseWithParamater:(NSString*)thisParam ofType:(id)supportedType;
+(VMTalkPhase*)phaseWithParamater:(NSString*)thisParam ofType:(id)supportedType withName:(NSString*)thisName;
+(VMTalkPhase*)phaseWithParamater:(NSString*)thisParam ofType:(id)supportedType withName:(NSString*)thisName withDescription:(NSString*)thisDescription;


-(void)setSupportedDataTypeAsClass:(Class)supportedType;
-(void)setSupportedDataAsTypeClassArray:(NSArray*)supportedTypes;
-(void)addSupportedDataTypeAsClass:(Class)supportedType;
-(void)addSupportedDataTypeAsClassArray:(NSArray*)supportedTypes;
-(void)enumerateSupportDataTypesAsClass:(void (^) (Class thisDatatypeAsClass))block;
-(BOOL)doesSupportDataType:(Class)dataTypeAsClass;
-(BOOL)doesSupportDataTypes:(NSArray*)dataTypesAsClassArray;
@end


@interface VMTalkPhase : NSObject <VMTalkPhaseExport>
@end