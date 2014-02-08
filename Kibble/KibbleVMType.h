//
//  KibbleVMType.h
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMObject.h"

@protocol KibbleVMTypeExport  <KibbleVMObjectExport>
@end


@interface KibbleVMType : VMObject <KibbleVMTypeExport>

@end
