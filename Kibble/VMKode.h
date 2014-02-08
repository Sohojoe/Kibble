//
//  KibbleVMKode.h
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "VMObject.h"

@class VMTalk;

@protocol VMKodekExport  <VMObjectExport>
@property (nonatomic, strong,readonly) id result;           // reading this runs the kode
-(void)setKibbleKodeAsNativeVMScript:(id)thisKibbleKode;    // this sets the kode
@end

@interface VMKode : VMObject <VMKodekExport>

@end

