//
//  VMInstance.h
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//



#import "VMObject.h"

@protocol VMInstanceExport  <VMObjectExport>
@end


@interface VMInstance : VMObject <VMInstanceExport>

@end



