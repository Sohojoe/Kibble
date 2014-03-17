//
//  FZAClassDefinition.h
//  ObjectiveBrowser
//
//  Created by Graham Lee on 05/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FZAMethodDefinition;
@class FZACategoryDefinition;
@class FZAPropertyDefinition;

@interface FZAClassDefinition : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) FZAClassDefinition *superclass;
@property (nonatomic, readonly) NSArray *methods;
@property (nonatomic, readonly) NSArray *classMethods;
@property (nonatomic, readonly) NSArray *instanceMethods;
@property (nonatomic, readonly) NSArray *categories;
@property (nonatomic, readonly) NSArray *properties;

- (FZAMethodDefinition *)methodAtIndex: (NSUInteger)index;
- (NSUInteger)countOfMethods;
- (void)insertObject: (FZAMethodDefinition *)object inMethodsAtIndex: (NSUInteger)index;

- (FZACategoryDefinition *)categoryAtIndex: (NSUInteger)index;
- (NSUInteger)countOfCategories;
- (void)insertObject: (FZACategoryDefinition *)object inCategoriesAtIndex: (NSUInteger)index;

- (FZAPropertyDefinition *)propertyAtIndex: (NSUInteger)index;
- (NSUInteger)countOfProperties;
- (void)insertObject: (FZAPropertyDefinition *)object inPropertiesAtIndex: (NSUInteger)index;

@end
