//
//  FZAPropertyDefinition.h
//  ObjectiveBrowser
//
//  Created by Graham Lee on 07/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FZAPropertyAccessReadOnly = 0,
    FZAPropertyAccessReadWrite
} FZAPropertyAccess;

@interface FZAPropertyDefinition : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) FZAPropertyAccess access;

@end
