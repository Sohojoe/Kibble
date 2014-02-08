//
//  KibbleVMInstance.h
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//



#import "KibbleVMObject.h"

@protocol KibbleVMInstanceExport  <KibbleVMObjectExport>
@end


@interface KibbleVMInstance : KibbleVMObject <KibbleVMInstanceExport>

@end



