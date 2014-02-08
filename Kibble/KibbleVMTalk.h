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

@end




