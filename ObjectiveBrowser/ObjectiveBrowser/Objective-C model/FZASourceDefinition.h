//
//  FZASourceDeclaration.h
//  ObjectiveBrowser
//
//  Created by Graham Lee on 12/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FZASourceDefinition : NSObject

@property (nonatomic, copy) NSString *file;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, copy) NSString *definition;

@end
