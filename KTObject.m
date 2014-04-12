//
//  KTObject.m
//  Kibble
//
//  Created by Joe on 4/11/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KTObject.h"

@implementation KTObject
+(instancetype)objectFor:(id)aObject from:(Class)aClass{
    KTObject *o = [KTObject alloc];
    o = [o initWithObjectFor:aObject from:aClass];
    return o;
}
-(instancetype)initWithObjectFor:(id)aObject from:(Class)aClass{
    self = [super init];
    
    if (self) {
        _theObject = aObject;
        _theObjectClass = aClass;
    }
    return self;
}

@end
