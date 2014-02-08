//
//  KibbleVMTalk.h
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "VMObject.h"
#import "VMTalkPhaseData.h"



@protocol KibbleVMTalkExport  <KibbleVMObjectExport>
-(void)addPhaseWith:(VMTalkPhaseData*)thisTalkPhaseData;
-(void)setKibbleKode:(id)thisKibbleKode;
-(JSValue*)resultForTheseParamaters:(NSArray*)params;

// interface to reading the phases of talk
@property (nonatomic, readonly)NSUInteger totalPhases;         // returns how many phases in the talk

-(void)forThisPhase:(NSUInteger)phaseIndex findPhaseData:(void (^)(VMTalkPhaseData *thisTalkPhaseData))detailsBlock;
-(void)enumeratePhases:(void (^)(VMTalkPhaseData* thisTalkPhaseData))detailsBlock;
-(BOOL)isNextPhaseForTheseParamaters:(NSArray*)params;
-(void)ifNextPhaseForTheseParamaters:(NSArray*)params findPhaseData:(void (^)(VMTalkPhaseData* thisTalkPhaseData))detailsBlock;
-(BOOL)isDataTypeSupported:(id)thisData forNextPhaseForTheseParamaters:(NSArray*)params;
-(BOOL)isDataTypeSupported:(id)thisData forThisPhase:(NSUInteger)phaseIndex;

@end


@interface KibbleVMTalk : VMObject <KibbleVMTalkExport>

@end



