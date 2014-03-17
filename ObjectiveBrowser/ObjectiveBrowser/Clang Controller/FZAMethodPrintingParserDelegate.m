//
//  FZAMethodPrintingParserDelegate.m
//  ObjectiveBrowser
//
//  Created by Graham Lee on 07/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import "FZAMethodPrintingParserDelegate.h"
#import "FZAClassParser.h"

@implementation FZAMethodPrintingParserDelegate

- (void)classParser:(FZAClassParser *)parser foundDeclaration:(const CXIdxDeclInfo *)declaration {
    const char * const name = declaration->entityInfo->name;
    switch (declaration->entityInfo->kind) {
        case CXIdxEntity_ObjCProtocol:
        {
            NSLog(@"@protocol %s\n", name);
            break;
        }
        case CXIdxEntity_ObjCCategory:
        {
            NSLog(@" (%s)\n", name);
            break;
        }
        case CXIdxEntity_ObjCClass:
        {
            NSLog(@"@interface %s\n",name);
            break;
        }
        case CXIdxEntity_ObjCClassMethod:
        {
            NSLog(@"\t+%s\n", name);
            break;
        }
        case CXIdxEntity_ObjCInstanceMethod:
        {
            NSLog(@"\t-%s\n", name);
            break;
        }
        case CXIdxEntity_ObjCProperty:
        {
            NSLog(@"\t@property %s\n", name);
            break;
        }
        default:
            break;
    }
}

@end
