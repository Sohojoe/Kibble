//
//  FZAMethodDefinition.h
//  ObjectiveBrowser
//
//  Created by Graham Lee on 05/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FZAMethodClass = 0,
    FZAMethodInstance,
} FZAMethodType;

@class FZASourceDefinition;
@interface FZAMethodDefinition : NSObject

@property (nonatomic, assign) FZAMethodType type;
@property (nonatomic, copy) NSString * selector;
@property (nonatomic, strong) FZASourceDefinition *sourceCode;
@property (nonatomic, strong) NSString *objCNameStyle;

@end
