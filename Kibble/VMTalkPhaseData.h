//
//  TalkPhaseData.h
//  Kibble
//
//  Created by Joe on 2/8/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMObject.h"

@class VMTalkPhaseData;

@protocol VMTalkPhaseDataExport <KibbleVMObjectExport>
// enherits name from VMObject
// enherits description from VMObject
@property (nonatomic, strong) NSString *paramater;
@property (nonatomic, strong, readonly) NSArray* supportedDataTypesAsClassArray;

+(VMTalkPhaseData*)phaseWithParamater:(NSString*)thisParam;
+(VMTalkPhaseData*)phaseWithParamater:(NSString*)thisParam ofType:(id)supportedType;
+(VMTalkPhaseData*)phaseWithParamater:(NSString*)thisParam ofType:(id)supportedType withName:(NSString*)thisName;
+(VMTalkPhaseData*)phaseWithParamater:(NSString*)thisParam ofType:(id)supportedType withName:(NSString*)thisName withDescription:(NSString*)thisDescription;


-(void)setSupportedDataTypeAsClass:(Class)supportedType;
-(void)setSupportedDataAsTypeClassArray:(NSArray*)supportedTypes;
-(void)addSupportedDataTypeAsClass:(Class)supportedType;
-(void)addSupportedDataTypeAsClassArray:(NSArray*)supportedTypes;
-(void)enumerateSupportDataTypesAsClass:(void (^) (Class thisDatatypeAsClass))block;
-(BOOL)doesSupportDataType:(Class)dataTypeAsClass;
-(BOOL)doesSupportDataTypes:(NSArray*)dataTypesAsClassArray;
@end


@interface VMTalkPhaseData : NSObject <VMTalkPhaseDataExport>
@end