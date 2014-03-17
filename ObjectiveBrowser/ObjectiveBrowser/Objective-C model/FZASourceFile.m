//
//  FZASourceFile.m
//  ObjectiveBrowser
//
//  Created by Graham Lee on 13/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FZASourceFile.h"

@implementation FZASourceFile

@synthesize path;
@synthesize frameworkFile;

- (NSString *)fileName {
    return [path lastPathComponent];
}

- (NSData *)content {
    return [NSData dataWithContentsOfMappedFile: path];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ file <%@>", self.frameworkFile?@"framework":@"source", self.fileName];
}

@end
