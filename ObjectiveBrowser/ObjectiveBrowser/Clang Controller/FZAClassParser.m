//
//  FZAClassParser.m
//  ObjectiveBrowser
//
//  Created by Graham Lee on 07/05/2012.
//  Copyright (c) 2012 Fuzzy Aliens Ltd.. All rights reserved.
//

#import "FZAClassParser.h"
#import "FZAClassParserDelegate.h"
#import "../../../KTClassRnD.h"

int abortQuery(CXClientData client_data, void *reserved);
void diagnostic(CXClientData client_data,
                CXDiagnosticSet diagnostic_set, void *reserved);
CXIdxClientFile enteredMainFile(CXClientData client_data,
                                CXFile mainFile, void *reserved);
CXIdxClientFile ppIncludedFile(CXClientData client_data,
                               const CXIdxIncludedFileInfo *included_file);
CXIdxClientASTFile importedASTFile(CXClientData client_data,
                                   const CXIdxImportedASTFileInfo *imported_ast);
CXIdxClientContainer startedTranslationUnit(CXClientData client_data,
                                            void *reserved);
void indexDeclaration(CXClientData client_data,
                      const CXIdxDeclInfo *declaration);
void indexEntityReference(CXClientData client_data,
                          const CXIdxEntityRefInfo *entity_reference);

static IndexerCallbacks indexerCallbacks = {
    .abortQuery = abortQuery,
    .diagnostic = diagnostic,
    .enteredMainFile = enteredMainFile,
    .ppIncludedFile = ppIncludedFile,
    .importedASTFile = importedASTFile,
    .startedTranslationUnit = startedTranslationUnit,
    .indexDeclaration = indexDeclaration,
    .indexEntityReference = indexEntityReference
};

@interface FZAClassParser ()

- (void)realParse;

@end

@implementation FZAClassParser
{
    NSString *sourceFile;
    NSOperationQueue *queue;
}

@synthesize delegate;

- (id)initWithSourceFile:(NSString *)implementation {
    if ((self = [super init])) {
        if(![[NSFileManager defaultManager] fileExistsAtPath: implementation]) {
            return nil;
        }
        sourceFile = [implementation copy];
        queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)parse {
    __weak id parser = self;
    [queue addOperationWithBlock: ^{ [parser realParse]; }];
}

- (void)realParse {
#pragma warning Pass errors back to the app
    @autoreleasepool {
        CXIndex index = clang_createIndex(1, 1);
        if (!index) {
            NSLog(@"fail: couldn't create translation unit");
            return;
        }
        // -I - F etc
        const char* iOSArgs[] = {
            "-isysroot/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator7.1.sdk",
            "-I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include",
            "-I/usr/local/include",
            "-I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/5.1/include",
            "-I/Users/apple/development/Kibble/Kibble",
        };

        const char* osXArgs[] = {
            "-isysroot/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk",
            "-I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include",
            "-I/usr/local/include",
            "-I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/5.1/include",
            //"-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/usr/include/c++/4.2.1/tr1",
            //"-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/Library/Frameworks/Kernel.framework/Versions/A/Headers",
            
            //"-I /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/Library/Frameworks",
            //"-F /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/Library/Frameworks",
            //"-iframework /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/",
        };

        CXTranslationUnit translationUnit;
        
        if (NO) {
            // lets get from ast file or try my and see what happening
            translationUnit = clang_createTranslationUnit(index,
                                                         [sourceFile fileSystemRepresentation]);
            
        } else {
            // old style
            translationUnit = clang_parseTranslationUnit(index,
                                                         [sourceFile fileSystemRepresentation],
                                                         iOSArgs,
                                                         5,
                                                         NULL, 0,
                                                         CXTranslationUnit_DetailedPreprocessingRecord
                                                         //+ CXTranslationUnit_PrecompiledPreamble
                                                         //+ CXTranslationUnit_CacheCompletionResults
                                                         //+ CXTranslationUnit_ForSerialization
                                                         //+ CXTranslationUnit_SkipFunctionBodies
                                                         + CXTranslationUnit_IncludeBriefCommentsInCodeCompletion
                                                         );
        }
        
        
        
        
        if (!translationUnit) {
            NSLog(@"fail: couldn't compile %@", sourceFile);
            return;
        }
        CXIndexAction action = clang_IndexAction_create(index);
        if ([self.delegate respondsToSelector: @selector(classParser:willBeginParsingFile:)]) {
            [self.delegate classParser: self willBeginParsingFile: sourceFile];
        }
        int indexResult = clang_indexTranslationUnit(action,
                                                     (__bridge CXClientData)self,
                                                     &indexerCallbacks,
                                                     sizeof(indexerCallbacks),
                                                     CXIndexOpt_SuppressWarnings,
                                                     translationUnit);
        if ([self.delegate respondsToSelector: @selector(classParser:didFinishParsingFile:)]) {
            [self.delegate classParser: self didFinishParsingFile: sourceFile];
        }
        clang_IndexAction_dispose(action);
        clang_disposeTranslationUnit(translationUnit);
        clang_disposeIndex(index);
        (void) indexResult;
    }
    
    [KTFoundation enumerateFoundations:^(KTFoundation *aFoundation) {
        NSLog(@"%@", aFoundation.name);
        [aFoundation saveToOSXDisk];
    }];}

@end

int abortQuery(CXClientData client_data, void *reserved) {
    @autoreleasepool {
        FZAClassParser *parser = (__bridge FZAClassParser *)client_data;
        if ([parser.delegate respondsToSelector: @selector(classParserShouldAbort:)]) {
            return [parser.delegate classParserShouldAbort: parser];
        }
        return 0;
    }
}

void diagnostic(CXClientData client_data,
                CXDiagnosticSet diagnostic_set, void *reserved) {
    @autoreleasepool {
        FZAClassParser *parser = (__bridge FZAClassParser *)client_data;
        if ([parser.delegate respondsToSelector: @selector(classParser:foundDiagnostics:)]) {
            [parser.delegate classParser: parser foundDiagnostics: diagnostic_set];
        }
    }
}

CXIdxClientFile enteredMainFile(CXClientData client_data,
                                CXFile mainFile, void *reserved) {
    @autoreleasepool {
        FZAClassParser *parser = (__bridge FZAClassParser *)client_data;
        if ([parser.delegate respondsToSelector: @selector(classParser:enteredMainFile:)]) {
            return [parser.delegate classParser: parser enteredMainFile: mainFile];
        }
        return NULL;
    }
}

CXIdxClientFile ppIncludedFile(CXClientData client_data,
                               const CXIdxIncludedFileInfo *included_file) {
    @autoreleasepool {
        FZAClassParser *parser = (__bridge FZAClassParser *)client_data;
        if ([parser.delegate respondsToSelector: @selector(classParser:includedFile:)]) {
            return [parser.delegate classParser: parser includedFile: included_file];
        }
        return NULL;
    }
}

CXIdxClientASTFile importedASTFile(CXClientData client_data,
                                   const CXIdxImportedASTFileInfo *imported_ast) {
    @autoreleasepool {
        FZAClassParser *parser = (__bridge FZAClassParser *)client_data;
        if ([parser.delegate respondsToSelector: @selector(classParser:importedPCH:)]) {
            return [parser.delegate classParser: parser importedPCH: imported_ast];
        }
        return NULL;
    }
}

CXIdxClientContainer startedTranslationUnit(CXClientData client_data,
                                            void *reserved) {
    @autoreleasepool {
        FZAClassParser *parser = (__bridge FZAClassParser *)client_data;
        if ([parser.delegate respondsToSelector: @selector(classParserStartedTranslationUnit:)]) {
            return [parser.delegate classParserStartedTranslationUnit: parser];
        }
        return NULL;
    }
}

void indexDeclaration(CXClientData client_data,
                      const CXIdxDeclInfo *declaration) {
    @autoreleasepool {
        FZAClassParser *parser = (__bridge FZAClassParser *)client_data;
        if ([parser.delegate respondsToSelector: @selector(classParser:foundDeclaration:)]) {
            [parser.delegate classParser: parser foundDeclaration: declaration];
        }
    }
}

void indexEntityReference(CXClientData client_data,
                          const CXIdxEntityRefInfo *entity_reference) {
    @autoreleasepool {
        FZAClassParser *parser = (__bridge FZAClassParser *)client_data;
        if ([parser.delegate respondsToSelector: @selector(classParser:foundEntityReference:)]) {
            [parser.delegate classParser: parser foundEntityReference: entity_reference];
        }
    }
}
