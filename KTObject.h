//
//  KTObject.h
//  Kibble
//
//  Created by Joe on 4/11/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KTObject : NSObject
@property (nonatomic, readonly, strong) id theObject;
@property (nonatomic, readonly, strong) Class theObjectClass;
+(instancetype)objectFor:(id)aObject from:(Class)aClass;
@end
