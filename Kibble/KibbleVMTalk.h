//
//  KibbleVMTalk.h
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KibbleVMObject.h"

@protocol KibbleVMTalkExport  <KibbleVMObjectExport>

-(void)addTalkToParamater:(id)thisParamater paramaterName:(NSString*)thisParamateName andDescription:(NSString*)thisDescription;

-(void)addKibbleKode:(id)thisKibbleKode;

-(JSValue*)resultForTheseParamaters:(NSArray*)params;

@end


@interface KibbleVMTalk : KibbleVMObject <KibbleVMTalkExport>


//--------------------------------------------------
// for internal use between classes
@property (nonatomic, strong) JSValue *function;
@property (nonatomic, strong) NSString *script;
@property (nonatomic, strong) NSMutableDictionary* paramaters;
@property (nonatomic, strong) NSMutableArray *orderedParamatersKeys;
@property (nonatomic, strong) NSString* kibbleKode;
@end

@interface KibbleVMTalk (private)
@end


//--------------------------------------------------
// for internal use between classes
@interface KTParam : NSObject
@property (nonatomic, strong) NSString *paramater;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@end
