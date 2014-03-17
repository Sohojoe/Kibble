//
//  CXTypeObjC+Private.m
//  ObjectiveBrowser
//
//  Created by Joe on 3/8/14.
//
//

#import "CXTypeObjC+Private.h"

@implementation CXTypeObjC (Private)
@dynamic type;
+(CXTypeObjC *)typeFrom:(CXType) thisType{
    CXTypeObjC * t = [[CXTypeObjC alloc]initWith:thisType];
    return t;
}
-(CXTypeObjC *)initWith:(CXType) thisType{
    self = [super init];
    if (self) {
        self.type = thisType;
    }
    return self;
}

@end
