//
// Created by leeg on 07/05/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class FZAClassDefinition;
@class FZASourceFile;

@interface FZAClassGroup : NSObject

@property (nonatomic, copy) NSString *name;
@property (readonly) NSArray *classes;
@property (readonly) NSArray *files;

- (void)insertObject: (FZAClassDefinition *)classDefinition inClassesAtIndex: (NSUInteger)index;
- (FZAClassDefinition *)objectInClassesAtIndex: (NSUInteger)index;
- (NSUInteger)countOfClasses;
- (FZAClassDefinition *)classNamed: (NSString *)className;

- (void)insertObject:(FZASourceFile *)object inFilesAtIndex:(NSUInteger)index;
- (FZASourceFile *)objectInFilesAtIndex: (NSUInteger)index;
- (NSUInteger)countOfFiles;
@end