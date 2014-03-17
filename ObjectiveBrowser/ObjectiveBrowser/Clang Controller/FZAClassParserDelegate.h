//
//  FZAClassParserDelegate.h
//  ObjectiveBrowser
//
//  Created by Graham Lee on 07/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <clang-c/Index.h>

@class FZAClassParser;
@protocol FZAClassParserDelegate <NSObject>

@optional

- (void)classParser: (FZAClassParser *)parser willBeginParsingFile: (NSString *)path;
- (void)classParser:(FZAClassParser *)parser didFinishParsingFile:(NSString *)path;
- (BOOL)classParserShouldAbort: (FZAClassParser *)parser;
- (void)classParser: (FZAClassParser *)parser foundDiagnostics: (CXDiagnosticSet)diagnostics;
- (CXIdxClientFile)classParser: (FZAClassParser *)parser enteredMainFile: (CXFile)mainFile;
- (CXIdxClientFile)classParser: (FZAClassParser *)parser includedFile: (const CXIdxIncludedFileInfo *)includedFile;
- (CXIdxClientASTFile)classParser: (FZAClassParser *)parser importedPCH: (const CXIdxImportedASTFileInfo *)precompiledHeader;
- (CXIdxClientContainer)classParserStartedTranslationUnit: (FZAClassParser *)parser;
- (void)classParser: (FZAClassParser *)parser foundDeclaration: (const CXIdxDeclInfo *)declaration;
- (void)classParser: (FZAClassParser *)parser foundEntityReference: (const CXIdxEntityRefInfo *)entityReference;

@end
