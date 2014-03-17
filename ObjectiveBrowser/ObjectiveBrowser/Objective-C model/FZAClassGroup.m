//
// Created by leeg on 07/05/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FZAClassGroup.h"
#import "FZAClassDefinition.h"

@implementation FZAClassGroup {
    NSMutableDictionary *classes;
    NSMutableArray *files;
}

- (id)init {
    if ((self = [super init])) {
        classes = [[NSMutableDictionary alloc] init];
        files = [[NSMutableArray alloc] init];
    }
    return self;
}

@synthesize name;
@synthesize files;

- (NSArray *)classes {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"name" ascending: YES];
    return [[classes allValues] sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortDescriptor]];
}

- (void)insertObject:(FZAClassDefinition *)classDefinition inClassesAtIndex:(NSUInteger)index {
    [classes setObject: classDefinition forKey: classDefinition.name];
}

- (FZAClassDefinition *)objectInClassesAtIndex:(NSUInteger)index {
    return [self.classes objectAtIndex: index];
}

- (NSUInteger)countOfClasses {
    return [classes count];
}

- (FZAClassDefinition *)classNamed:(NSString *)className {
    return [classes objectForKey: className];
}

- (void)insertObject:(FZASourceFile *)object inFilesAtIndex:(NSUInteger)index {
    [files insertObject: object atIndex: index];
}

- (FZASourceFile *)objectInFilesAtIndex: (NSUInteger)index {
    return [files objectAtIndex: index];
}

- (NSUInteger)countOfFiles {
    return [files count];
}

@end