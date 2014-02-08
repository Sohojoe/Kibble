//
//  KibbleVMTalk.h
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KibbleVMObject.h"

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


@protocol KibbleVMTalkExport  <KibbleVMObjectExport>
-(void)addParamaterPhase:(id)thisParamater supportedDataType:(SupportedDataTypes)supportedData paramaterName:(NSString*)thisParamateName andDescription:(NSString*)thisDescription;
-(void)setKibbleKode:(id)thisKibbleKode;
-(JSValue*)resultForTheseParamaters:(NSArray*)params;

// interface to reading the phases of talk
@property (nonatomic, readonly)NSUInteger totalPhases;                 // returns how many phases in the talk
-(void)forThisPhase:(NSUInteger)thisPhase findDetails:(void (^)(id paramater, SupportedDataTypes supportedData, NSString* name, NSString* description))detailsBlock;
-(void)enumeratePhases:(void (^)(id paramater, SupportedDataTypes supportedData, NSString* name, NSString* description))detailsBlock;
-(BOOL)isNextPhaseForTheseParamaters:(NSArray*)params;
-(void)ifNextPhaseForTheseParamaters:(NSArray*)params findDetails:(void (^)(id paramater, SupportedDataTypes supportedData, NSString* name, NSString* description))detailsBlock;
-(BOOL)isDataTypeSupported:(id)thisDate forNextPhaseForTheseParamaters:(NSArray*)params;
-(BOOL)isDataTypeSupported:(id)thisDate forThisPhase:(NSUInteger)thisPhase;

@end


@interface KibbleVMTalk : KibbleVMObject <KibbleVMTalkExport>

@end



