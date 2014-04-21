//
//  KTObject.h
//  Kibble
//
//  Created by Joe on 4/11/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KTType;

@interface KTObject : NSObject
@property (nonatomic, readonly, strong) id theObject;
@property (nonatomic, readonly, strong) Class theObjectClass;
@property (nonatomic, readonly) BOOL isCType;
@property (nonatomic, readonly, strong) NSValue *theValue;
@property (nonatomic, readonly, strong) KTType* theValueCType;

+(instancetype)objectFor:(id)aObject from:(Class)aClass;
+(instancetype)objectForValue:(NSValue*)aValue ofType:(KTType*)aType;
/// YES if this is the class object, NO if this is an intance object
@property (nonatomic, readonly) BOOL isClassObject;

@end
