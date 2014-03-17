//
//  CXTypeObjC+Private.h
//  ObjectiveBrowser
//
//  Created by Joe on 3/8/14.
//
//

#import "CXTypeObjC.h"
#import <clang-c/Index.h>

@interface CXTypeObjC (Private)
@property (nonatomic) CXType type;
+(CXTypeObjC *)typeFrom:(CXType) thisType;
-(CXTypeObjC *)initWith:(CXType) thisType;
@end
