//
// Created by leeg on 07/05/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <clang-c/Index.h>
#import "FZAModelBuildingParserDelegate.h"
#import "FZAClassGroup.h"
#import "FZAClassDefinition.h"
#import "FZAMethodDefinition.h"
#import "FZAPropertyDefinition.h"
#import "FZASourceDefinition.h"
#import "FZASourceFile.h"
#import "../../../KTClassRnD.h"
//#define __STDC_LIMIT_MACROS
//#define __STDC_CONSTANT_MACROS
//#import <clang/AST/ExprObjC.h>

#import "CXCursorObjC.h"
#import "CXTypeObjC.h"

@interface FZAModelBuildingParserDelegate()
@property (nonatomic, strong) KTFoundation *theCurrentFoundation;
@property (nonatomic, strong) KTClass *theCurrentClass;
@end
@implementation FZAModelBuildingParserDelegate {
    FZAClassGroup *group;
    FZAClassDefinition *currentClass;
    NSData *fileContent;
    NSString *fileName;
}

- (id)initWithClassGroup:(FZAClassGroup *)classGroup {
    if ((self = [super init])) {
        group = classGroup;
    }
    return self;
}

- (void)classParser: (FZAClassParser *)parser willBeginParsingFile: (NSString *)path {
    fileContent = [NSData dataWithContentsOfMappedFile: path];
    fileName = [path lastPathComponent];
}

- (void)classParser:(FZAClassParser *)parser didFinishParsingFile:(NSString *)path {
    fileContent = nil;
    fileName = nil;
}

- (void)classParser:(FZAClassParser *)parser foundDeclaration:(CXIdxDeclInfo const *)declaration {
    const char * const name = declaration->entityInfo->name;
    if (name == NULL) return; //not much we could do anyway.
    NSString *declarationName = [NSString stringWithUTF8String: name];

    switch (declaration->entityInfo->kind) {
        case CXIdxEntity_ObjCProtocol:
        {
            currentClass = nil;
            break;
        }
        case CXIdxEntity_ObjCCategory:
        {
            const CXIdxObjCCategoryDeclInfo *categoryInfo = 
            clang_index_getObjCCategoryDeclInfo(declaration);
            NSString *className = [NSString stringWithUTF8String: categoryInfo->objcClass->name];
            FZAClassDefinition *classDefinition =[group classNamed: className];
            if (!classDefinition) {
                classDefinition = [[FZAClassDefinition alloc] init];
                classDefinition.name = className;
                [group insertObject: classDefinition inClassesAtIndex: [group countOfClasses]];
            }
            currentClass = classDefinition;
            break;
        }
        case CXIdxEntity_ObjCClass:
        {
            FZAClassDefinition *classDefinition =[group classNamed: declarationName];
            if (!classDefinition) {
                classDefinition = [[FZAClassDefinition alloc] init];
                classDefinition.name = declarationName;
                [group insertObject: classDefinition inClassesAtIndex: [group countOfClasses]];
            }
            currentClass = classDefinition;
            
            // handle this class and create it if needed
            if (!self.theCurrentFoundation) {
                self.theCurrentFoundation = [KTFoundation foundationWithName:@"TestFoundation"];
            }
            
            KTClass *thisClass = [self.theCurrentFoundation classWithName:declarationName];
            if (!thisClass) {
                thisClass = [KTClass classWithName:declarationName];
                [self.theCurrentFoundation addClass:thisClass];
            }
            self.theCurrentClass = thisClass;
            
            break;
        }
        case CXIdxEntity_ObjCClassMethod:
        case CXIdxEntity_ObjCInstanceMethod:
        {
            if (declaration->isImplicit) {
                break;
            }
            FZAMethodDefinition *method = [[FZAMethodDefinition alloc] init];
            method.selector = declarationName;
            if (declaration->entityInfo->kind == CXIdxEntity_ObjCClassMethod)
                method.type = FZAMethodClass;
            else
                method.type = FZAMethodInstance;
            
            CXCursor cursor = declaration->entityInfo->cursor;
            CXCursorObjC *cursorObjC = [CXCursorObjC cursorFromPointer:&cursor];            
            method.objCNameStyle = cursorObjC.debugDescription;
            
            if (declaration->isDefinition) {
                CXSourceRange range = clang_getCursorExtent(declaration->cursor);
                CXSourceLocation start = clang_getRangeStart(range);
                CXSourceLocation end = clang_getRangeEnd(range);
                unsigned startOffset, endOffset;
                clang_getExpansionLocation(start, NULL, NULL, NULL, &startOffset);
                clang_getExpansionLocation(end, NULL, NULL, NULL, &endOffset);
                NSRange sourceRange = NSMakeRange(startOffset, endOffset - startOffset);
                NSData *definition = [fileContent subdataWithRange: sourceRange];
                NSString *definitionCode = [[NSString alloc] initWithData: definition encoding: NSUTF8StringEncoding];
                FZASourceDefinition *source = [[FZASourceDefinition alloc] init];
                source.file = fileName;
                source.range = sourceRange;
                source.definition = definitionCode;
                method.sourceCode = source;
                //[currentClass insertObject: method inMethodsAtIndex: [currentClass countOfMethods]];
            }
            [currentClass insertObject: method inMethodsAtIndex: [currentClass countOfMethods]];

            
            // handle creating method
            __block KTMethod *thisMethod = [KTMethod new];
            __block NSMutableArray *params = [NSMutableArray new];
            [cursorObjC enumerateMethodDecl:^(BOOL isClassMethod, BOOL isIntanceMethod, NSString *name, NSString *briefComment, NSString *rawComment, NSUInteger numParamaters) {
                thisMethod.isClass = isClassMethod;
                thisMethod.isInstance = isIntanceMethod;
                thisMethod.name = name;
                thisMethod.comment = briefComment;
            } result:^(BOOL isVoid, NSString *returnName, CXTypeObjC *returnType) {
                //
                KTType* thisReturnType = [self ktTypeFrom:returnType];
                thisMethod.returns = thisReturnType;
            } paramater:^(NSString *paramaterName, NSString *paramaterTypeAsString, NSString *briefComment, NSString *rawComment, CXTypeObjC *paramaterType, NSString *methodNameForParamater) {
                //
                KTType* thisParamType = [self ktTypeFrom:paramaterType];
                KTMethodParam* thisParam = [KTMethodParam newParam:paramaterName paramType:thisParamType commandName:methodNameForParamater comment:briefComment];
                [params addObject:thisParam];
            }];
            thisMethod.params = params;
            
            if (declaration->entityInfo->kind == CXIdxEntity_ObjCClassMethod) {
                [self.theCurrentClass addClassMethod:thisMethod];
            } else {
                [self.theCurrentClass addInstanceMethod:thisMethod];
            }

            
            break;
        }
        case CXIdxEntity_ObjCProperty:
        {
            const CXIdxObjCPropertyDeclInfo *propertyDeclaration = clang_index_getObjCPropertyDeclInfo(declaration);
            FZAPropertyDefinition *property = [[FZAPropertyDefinition alloc] init];
            property.title = declarationName;
            if (propertyDeclaration && propertyDeclaration->setter) {
                property.access = FZAPropertyAccessReadWrite;
            } else {
                property.access = FZAPropertyAccessReadOnly;
            }
            [currentClass insertObject: property inPropertiesAtIndex: [currentClass countOfProperties]];
            break;
        }
        default:
            break;
    }
}

-(KTType*)ktTypeFrom:(CXTypeObjC*)sourceType{
    KTType* thisType = nil;
    
    if (sourceType.rawKind == CXType_ObjCInterface) {
        thisType = [KTType objCInterface:thisType.name];
    } else if(sourceType.rawKind == CXType_ObjCObjectPointer){
        thisType = [KTType objCObjectPointer:thisType.name];
    }
    
    
    return thisType;
}

- (CXIdxClientFile)classParser:(FZAClassParser *)parser enteredMainFile:(CXFile)mainFile {
    FZASourceFile *file = [[FZASourceFile alloc] init];
    file.frameworkFile = NO;
    const char *mainPath = clang_getCString(clang_getFileName(mainFile));
    file.path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation: mainPath length: strlen(mainPath)];
    [group insertObject: file inFilesAtIndex: [group countOfFiles]];
    return (__bridge CXIdxClientFile)file;
}

- (CXIdxClientFile)classParser:(FZAClassParser *)parser includedFile:(const CXIdxIncludedFileInfo *)includedFile {
    FZASourceFile *file = [[FZASourceFile alloc] init];
    file.frameworkFile = includedFile->isAngled;
    const char *path = clang_getCString(clang_getFileName(includedFile->file));
    file.path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation: path length: strlen(path)];
    [group insertObject: file inFilesAtIndex: [group countOfFiles]];
    return (__bridge CXIdxClientFile)file;
}





@end