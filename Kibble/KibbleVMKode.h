//
//  KibbleVMKode.h
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "VMObject.h"

@class KibbleVMTalk;

@protocol KibbleVMKodekExport  <KibbleVMObjectExport>
@property (nonatomic, strong,readonly) id result;           // reading this runs the kode
-(void)setKibbleKodeAsNativeVMScript:(id)thisKibbleKode;    // this sets the kode
@end

@interface KibbleVMKode : VMObject <KibbleVMKodekExport>

@end

