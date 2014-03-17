//
//  FZAClassDefinition.m
//  ObjectiveBrowser
//
//  Created by Graham Lee on 05/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import "FZAClassDefinition.h"
#import "FZAMethodDefinition.h"
#import "FZAPropertyDefinition.h"

@implementation FZAClassDefinition
{
    NSMutableArray *methods;
    NSMutableArray *categories;
    NSMutableArray *properties;
}

@synthesize name;
@synthesize superclass;

- (id)init {
    if ((self = [super init])) {
        methods = [[NSMutableArray alloc] init];
        categories = [[NSMutableArray alloc] init];
        properties = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)classMethods {
    NSIndexSet *classMethodIndices = [methods indexesOfObjectsPassingTest: ^(id obj, NSUInteger index, BOOL *stop) {
        FZAMethodDefinition *method = (FZAMethodDefinition *)obj;
        return (BOOL)(method.type == FZAMethodClass);
    }];
    return [methods objectsAtIndexes: classMethodIndices];
}

- (NSArray *)instanceMethods {
    NSIndexSet *instanceMethodIndices = [methods indexesOfObjectsPassingTest: ^(id obj, NSUInteger index, BOOL *stop) {
        FZAMethodDefinition *method = (FZAMethodDefinition *)obj;
        return (BOOL)(method.type == FZAMethodInstance);
    }];
    return [methods objectsAtIndexes: instanceMethodIndices];
}

- (FZAMethodDefinition *)methodAtIndex:(NSUInteger)index {
    return [methods objectAtIndex: index];
}

- (NSUInteger)countOfMethods {
    return [methods count];
}

- (void)insertObject:(FZAMethodDefinition *)object inMethodsAtIndex:(NSUInteger)index {
    [methods insertObject: object atIndex: index];
}

- (FZACategoryDefinition *)categoryAtIndex:(NSUInteger)index {
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unimplemented method" userInfo:nil] raise];
    return nil;
    //To change the template use AppCode | Preferences | File Templates.

}

- (NSUInteger)countOfCategories {
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unimplemented method" userInfo:nil] raise];
    return 0;
    //To change the template use AppCode | Preferences | File Templates.

}

- (void)insertObject:(FZACategoryDefinition *)object inCategoriesAtIndex:(NSUInteger)index {
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unimplemented method" userInfo:nil] raise];
    //To change the template use AppCode | Preferences | File Templates.

}

- (FZAPropertyDefinition *)propertyAtIndex:(NSUInteger)index {
    return [properties objectAtIndex: index];
}

- (NSUInteger)countOfProperties {
    return [properties count];
}

- (void)insertObject:(FZAPropertyDefinition *)object inPropertiesAtIndex:(NSUInteger)index {
    [properties insertObject: object atIndex: index];
}

- (NSArray *)methods {
    return [methods copy];
}

- (NSArray *)categories {
    return [categories copy];
}

- (NSArray *)properties {
    return [properties copy];
}

@end
