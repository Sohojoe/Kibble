//
//  FZAClassParser.h
//  ObjectiveBrowser
//
//  Created by Graham Lee on 07/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FZAClassParserDelegate;

@interface FZAClassParser : NSObject

@property (weak, nonatomic) id <FZAClassParserDelegate>delegate;

- (id)initWithSourceFile: (NSString *)implementation;
- (void)parse;

@end
