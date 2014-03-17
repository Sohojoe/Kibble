//
//  FZASourceFile.h
//  ObjectiveBrowser
//
//  Created by Graham Lee on 13/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FZASourceFile : NSObject

@property (nonatomic, copy) NSString *path;
@property (nonatomic, readonly) NSString *fileName;
@property (nonatomic, assign, getter = isFrameworkFile) BOOL frameworkFile;
@property (nonatomic, readonly) NSData *content;

@end
