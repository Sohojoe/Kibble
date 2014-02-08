//
//  VMTalk.h
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "VMObject.h"
#import "VMTalkPhase.h"



@protocol VMTalkExport  <VMObjectExport>
-(void)addPhaseWith:(VMTalkPhase*)thisTalkPhaseData;
-(void)setKibbleKode:(id)thisKibbleKode;
-(JSValue*)resultForTheseParamaters:(NSArray*)params;

// interface to reading the phases of talk
@property (nonatomic, readonly)NSUInteger totalPhases;         // returns how many phases in the talk

-(void)forThisPhase:(NSUInteger)phaseIndex findPhaseData:(void (^)(VMTalkPhase *thisTalkPhaseData))detailsBlock;
-(void)enumeratePhases:(void (^)(VMTalkPhase* thisTalkPhaseData))detailsBlock;
-(BOOL)isNextPhaseForTheseParamaters:(NSArray*)params;
-(void)ifNextPhaseForTheseParamaters:(NSArray*)params findPhaseData:(void (^)(VMTalkPhase* thisTalkPhaseData))detailsBlock;
-(BOOL)isDataTypeSupported:(id)thisData forNextPhaseForTheseParamaters:(NSArray*)params;
-(BOOL)isDataTypeSupported:(id)thisData forThisPhase:(NSUInteger)phaseIndex;

@end


@interface VMTalk : VMObject <VMTalkExport>

@end



