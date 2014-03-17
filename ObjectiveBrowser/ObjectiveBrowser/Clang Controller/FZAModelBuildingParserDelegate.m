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
//#define __STDC_LIMIT_MACROS
//#define __STDC_CONSTANT_MACROS
//#import <clang/AST/ExprObjC.h>

#import "CXCursorObjC.h"


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




-(void)outputMethodDetails:(CXCursor)thisMethodRaw{
    
    //CXCursorObjC *thisMethod = [CXCursorObjC cursorFromPointer:(__bridge id)(&thisMethodRaw)];
    CXCursorObjC *thisMethod = [CXCursorObjC cursorFromPointer:&thisMethodRaw];
    
    NSLog(@"%@", thisMethod.debugDescription);
    return;

    
    __block CXString str;
    str = clang_getCursorSpelling(thisMethodRaw);
    NSLog(@"%s = thisMethodRaw", clang_getCString(str));
    //NSLog(@"%s = clang_getCursorDisplayName(thisMethodRaw)", clang_getCString(clang_getCursorDisplayName(thisMethodRaw)));
    
    
    clang_visitChildrenWithBlock(thisMethodRaw, ^enum CXChildVisitResult(CXCursor cursor, CXCursor parent) {
        
        if (cursor.kind == CXCursor_TypeRef) {
            str = clang_getCursorSpelling(cursor);
            NSLog(@"%s = child", clang_getCString(str));
            //NSLog(@"%s = clang_getCursorDisplayName(child)", clang_getCString(clang_getCursorDisplayName(cursor)));
            
            //debig only
            str = clang_getCursorKindSpelling(cursor.kind);
            //NSLog(@"child Kind= %s", clang_getCString(str));
        }
        
        return CXChildVisit_Recurse;
        //return CXChildVisit_Recurse;
    });
    

    
    /**
     * Visits the children of a cursor using the specified block.  Behaves
     * identically to clang_visitChildren() in all other respects.
     */
    unsigned clang_visitChildrenWithBlock(CXCursor parent,
                                          CXCursorVisitorBlock block);
    
    /**
     * \brief Retrieve a name for the entity referenced by this cursor.
     */
    CINDEX_LINKAGE CXString clang_getCursorSpelling(CXCursor);
    
    /**
     * \defgroup CINDEX_DEBUG Debugging facilities
     *
     * These routines are used for testing and debugging, only, and should not
     * be relied upon.
     *
     * @{
     */
    
    /* for debug/testing */
    CINDEX_LINKAGE CXString clang_getCursorKindSpelling(enum CXCursorKind Kind);
    
    /**
     * \brief Retrieve the display name for the entity referenced by this cursor.
     *
     * The display name contains extra information that helps identify the cursor,
     * such as the parameters of a function or template or the arguments of a
     * class template specialization.
     */
    CINDEX_LINKAGE CXString clang_getCursorDisplayName(CXCursor);
    
    
    /**
     * \brief Retrieve the file that is included by the given inclusion directive
     * cursor.
     */
    CINDEX_LINKAGE CXFile clang_getIncludedFile(CXCursor cursor);
    /**
     * \brief Retrieve the type of a CXCursor (if any).
     */
    CINDEX_LINKAGE CXType clang_getCursorType(CXCursor C);
    
    /**
     * \brief Pretty-print the underlying type using the rules of the
     * language of the translation unit from which it came.
     *
     * If the type is invalid, an empty string is returned.
     */
    CINDEX_LINKAGE CXString clang_getTypeSpelling(CXType CT);
    
    /**
     * \brief Retrieve the underlying type of a typedef declaration.
     *
     * If the cursor does not reference a typedef declaration, an invalid type is
     * returned.
     */
    CINDEX_LINKAGE CXType clang_getTypedefDeclUnderlyingType(CXCursor C);
    
    /**
     * \brief Retrieve the integer type of an enum declaration.
     *
     * If the cursor does not reference an enum declaration, an invalid type is
     * returned.
     */
    CINDEX_LINKAGE CXType clang_getEnumDeclIntegerType(CXCursor C);
    
    /**
     * \brief Retrieve the integer value of an enum constant declaration as a signed
     *  long long.
     *
     * If the cursor does not reference an enum constant declaration, LLONG_MIN is returned.
     * Since this is also potentially a valid constant value, the kind of the cursor
     * must be verified before calling this function.
     */
    CINDEX_LINKAGE long long clang_getEnumConstantDeclValue(CXCursor C);
    
    /**
     * \brief Retrieve the integer value of an enum constant declaration as an unsigned
     *  long long.
     *
     * If the cursor does not reference an enum constant declaration, ULLONG_MAX is returned.
     * Since this is also potentially a valid constant value, the kind of the cursor
     * must be verified before calling this function.
     */
    CINDEX_LINKAGE unsigned long long clang_getEnumConstantDeclUnsignedValue(CXCursor C);
    
    /**
     * \brief Retrieve the bit width of a bit field declaration as an integer.
     *
     * If a cursor that is not a bit field declaration is passed in, -1 is returned.
     */
    CINDEX_LINKAGE int clang_getFieldDeclBitWidth(CXCursor C);
    
    /**
     * \brief Retrieve the number of non-variadic arguments associated with a given
     * cursor.
     *
     * The number of arguments can be determined for calls as well as for
     * declarations of functions or methods. For other cursors -1 is returned.
     */
    CINDEX_LINKAGE int clang_Cursor_getNumArguments(CXCursor C);
    
    /**
     * \brief Retrieve the argument cursor of a function or method.
     *
     * The argument cursor can be determined for calls as well as for declarations
     * of functions or methods. For other cursors and for invalid indices, an
     * invalid cursor is returned.
     */
    CINDEX_LINKAGE CXCursor clang_Cursor_getArgument(CXCursor C, unsigned i);
    
    /**
     * \brief Determine whether two CXTypes represent the same type.
     *
     * \returns non-zero if the CXTypes represent the same type and
     *          zero otherwise.
     */
    CINDEX_LINKAGE unsigned clang_equalTypes(CXType A, CXType B);
    
    /**
     * \brief Return the canonical type for a CXType.
     *
     * Clang's type system explicitly models typedefs and all the ways
     * a specific type can be represented.  The canonical type is the underlying
     * type with all the "sugar" removed.  For example, if 'T' is a typedef
     * for 'int', the canonical type for 'T' would be 'int'.
     */
    CINDEX_LINKAGE CXType clang_getCanonicalType(CXType T);
    
    /**
     * \brief Determine whether a CXType has the "const" qualifier set,
     * without looking through typedefs that may have added "const" at a
     * different level.
     */
    CINDEX_LINKAGE unsigned clang_isConstQualifiedType(CXType T);
    
    /**
     * \brief Determine whether a CXType has the "volatile" qualifier set,
     * without looking through typedefs that may have added "volatile" at
     * a different level.
     */
    CINDEX_LINKAGE unsigned clang_isVolatileQualifiedType(CXType T);
    
    /**
     * \brief Determine whether a CXType has the "restrict" qualifier set,
     * without looking through typedefs that may have added "restrict" at a
     * different level.
     */
    CINDEX_LINKAGE unsigned clang_isRestrictQualifiedType(CXType T);
    
    /**
     * \brief For pointer types, returns the type of the pointee.
     */
    CINDEX_LINKAGE CXType clang_getPointeeType(CXType T);
    
    /**
     * \brief Return the cursor for the declaration of the given type.
     */
    CINDEX_LINKAGE CXCursor clang_getTypeDeclaration(CXType T);
    
    /**
     * Returns the Objective-C type encoding for the specified declaration.
     */
    CINDEX_LINKAGE CXString clang_getDeclObjCTypeEncoding(CXCursor C);
    
    /**
     * \brief Retrieve the spelling of a given CXTypeKind.
     */
    CINDEX_LINKAGE CXString clang_getTypeKindSpelling(enum CXTypeKind K);
    
    /**
     * \brief Retrieve the calling convention associated with a function type.
     *
     * If a non-function type is passed in, CXCallingConv_Invalid is returned.
     */
    CINDEX_LINKAGE enum CXCallingConv clang_getFunctionTypeCallingConv(CXType T);
    
    /**
     * \brief Retrieve the return type associated with a function type.
     *
     * If a non-function type is passed in, an invalid type is returned.
     */
    CINDEX_LINKAGE CXType clang_getResultType(CXType T);
    
    /**
     * \brief Retrieve the number of non-variadic parameters associated with a
     * function type.
     *
     * If a non-function type is passed in, -1 is returned.
     */
    CINDEX_LINKAGE int clang_getNumArgTypes(CXType T);
    
    /**
     * \brief Retrieve the type of a parameter of a function type.
     *
     * If a non-function type is passed in or the function does not have enough
     * parameters, an invalid type is returned.
     */
    CINDEX_LINKAGE CXType clang_getArgType(CXType T, unsigned i);
    
    /**
     * \brief Return 1 if the CXType is a variadic function type, and 0 otherwise.
     */
    CINDEX_LINKAGE unsigned clang_isFunctionTypeVariadic(CXType T);
    
    /**
     * \brief Retrieve the return type associated with a given cursor.
     *
     * This only returns a valid type if the cursor refers to a function or method.
     */
    CINDEX_LINKAGE CXType clang_getCursorResultType(CXCursor C);
    CXType cursorResultType = clang_getCursorResultType(thisMethodRaw);
    //CXType resultType=clang_getResultType(cursorResultType);
    NSLog(@"%s = cursorResultType", clang_getCString(clang_getTypeSpelling(cursorResultType)));
    //NSLog(@"%s = resultType", clang_getCString(clang_getTypeSpelling(resultType)));
    int as=1;
    
    /**
     * \brief Return 1 if the CXType is a POD (plain old data) type, and 0
     *  otherwise.
     */
    CINDEX_LINKAGE unsigned clang_isPODType(CXType T);
    
    /**
     * \brief Return the element type of an array, complex, or vector type.
     *
     * If a type is passed in that is not an array, complex, or vector type,
     * an invalid type is returned.
     */
    CINDEX_LINKAGE CXType clang_getElementType(CXType T);
    
    /**
     * \brief Return the number of elements of an array or vector type.
     *
     * If a type is passed in that is not an array or vector type,
     * -1 is returned.
     */
    CINDEX_LINKAGE long long clang_getNumElements(CXType T);
    
    /**
     * \brief Return the element type of an array type.
     *
     * If a non-array type is passed in, an invalid type is returned.
     */
    CINDEX_LINKAGE CXType clang_getArrayElementType(CXType T);
    
    /**
     * \brief Return the array size of a constant array.
     *
     * If a non-array type is passed in, -1 is returned.
     */
    CINDEX_LINKAGE long long clang_getArraySize(CXType T);
    
    /**
     * \brief Return the alignment of a type in bytes as per C++[expr.alignof]
     *   standard.
     *
     * If the type declaration is invalid, CXTypeLayoutError_Invalid is returned.
     * If the type declaration is an incomplete type, CXTypeLayoutError_Incomplete
     *   is returned.
     * If the type declaration is a dependent type, CXTypeLayoutError_Dependent is
     *   returned.
     * If the type declaration is not a constant size type,
     *   CXTypeLayoutError_NotConstantSize is returned.
     */
    CINDEX_LINKAGE long long clang_Type_getAlignOf(CXType T);
    
    /**
     * \brief Return the class type of an member pointer type.
     *
     * If a non-member-pointer type is passed in, an invalid type is returned.
     */
    CINDEX_LINKAGE CXType clang_Type_getClassType(CXType T);
    
    /**
     * \brief Return the size of a type in bytes as per C++[expr.sizeof] standard.
     *
     * If the type declaration is invalid, CXTypeLayoutError_Invalid is returned.
     * If the type declaration is an incomplete type, CXTypeLayoutError_Incomplete
     *   is returned.
     * If the type declaration is a dependent type, CXTypeLayoutError_Dependent is
     *   returned.
     */
    CINDEX_LINKAGE long long clang_Type_getSizeOf(CXType T);
    
    /**
     * \brief Return the offset of a field named S in a record of type T in bits
     *   as it would be returned by __offsetof__ as per C++11[18.2p4]
     *
     * If the cursor is not a record field declaration, CXTypeLayoutError_Invalid
     *   is returned.
     * If the field's type declaration is an incomplete type,
     *   CXTypeLayoutError_Incomplete is returned.
     * If the field's type declaration is a dependent type,
     *   CXTypeLayoutError_Dependent is returned.
     * If the field's name S is not found,
     *   CXTypeLayoutError_InvalidFieldName is returned.
     */
    CINDEX_LINKAGE long long clang_Type_getOffsetOf(CXType T, const char *S);

    /**
     * \brief Returns non-zero if the cursor specifies a Record member that is a
     *   bitfield.
     */
    CINDEX_LINKAGE unsigned clang_Cursor_isBitField(CXCursor C);
    
    
    /**
     * \brief Retrieve a Unified Symbol Resolution (USR) for the entity referenced
     * by the given cursor.
     *
     * A Unified Symbol Resolution (USR) is a string that identifies a particular
     * entity (function, class, variable, etc.) within a program. USRs can be
     * compared across translation units to determine, e.g., when references in
     * one translation refer to an entity defined in another translation unit.
     */
    CINDEX_LINKAGE CXString clang_getCursorUSR(CXCursor);
    
    /**
     * \brief Construct a USR for a specified Objective-C class.
     */
    CINDEX_LINKAGE CXString clang_constructUSR_ObjCClass(const char *class_name);
    
    /**
     * \brief Construct a USR for a specified Objective-C category.
     */
    CINDEX_LINKAGE CXString
    clang_constructUSR_ObjCCategory(const char *class_name,
                                    const char *category_name);
    
    /**
     * \brief Construct a USR for a specified Objective-C protocol.
     */
    CINDEX_LINKAGE CXString
    clang_constructUSR_ObjCProtocol(const char *protocol_name);
    
    
    /**
     * \brief Construct a USR for a specified Objective-C instance variable and
     *   the USR for its containing class.
     */
    CINDEX_LINKAGE CXString clang_constructUSR_ObjCIvar(const char *name,
                                                        CXString classUSR);
    
    /**
     * \brief Construct a USR for a specified Objective-C method and
     *   the USR for its containing class.
     */
    CINDEX_LINKAGE CXString clang_constructUSR_ObjCMethod(const char *name,
                                                          unsigned isInstanceMethod,
                                                          CXString classUSR);
    
    /**
     * \brief Construct a USR for a specified Objective-C property and the USR
     *  for its containing class.
     */
    CINDEX_LINKAGE CXString clang_constructUSR_ObjCProperty(const char *property,
                                                            CXString classUSR);

    /** \brief For a cursor that is a reference, retrieve a cursor representing the
     * entity that it references.
     *
     * Reference cursors refer to other entities in the AST. For example, an
     * Objective-C superclass reference cursor refers to an Objective-C class.
     * This function produces the cursor for the Objective-C class from the
     * cursor for the superclass reference. If the input cursor is a declaration or
     * definition, it returns that declaration or definition unchanged.
     * Otherwise, returns the NULL cursor.
     */
    CINDEX_LINKAGE CXCursor clang_getCursorReferenced(CXCursor);
    
    /**
     *  \brief For a cursor that is either a reference to or a declaration
     *  of some entity, retrieve a cursor that describes the definition of
     *  that entity.
     *
     *  Some entities can be declared multiple times within a translation
     *  unit, but only one of those declarations can also be a
     *  definition. For example, given:
     *
     *  \code
     *  int f(int, int);
     *  int g(int x, int y) { return f(x, y); }
     *  int f(int a, int b) { return a + b; }
     *  int f(int, int);
     *  \endcode
     *
     *  there are three declarations of the function "f", but only the
     *  second one is a definition. The clang_getCursorDefinition()
     *  function will take any cursor pointing to a declaration of "f"
     *  (the first or fourth lines of the example) or a cursor referenced
     *  that uses "f" (the call to "f' inside "g") and will return a
     *  declaration cursor pointing to the definition (the second "f"
     *  declaration).
     *
     *  If given a cursor for which there is no corresponding definition,
     *  e.g., because there is no definition of that entity within this
     *  translation unit, returns a NULL cursor.
     */
    CINDEX_LINKAGE CXCursor clang_getCursorDefinition(CXCursor);
    
    /**
     * \brief Determine whether the declaration pointed to by this cursor
     * is also a definition of that entity.
     */
    CINDEX_LINKAGE unsigned clang_isCursorDefinition(CXCursor);
    
    /**
     * \brief Retrieve the canonical cursor corresponding to the given cursor.
     *
     * In the C family of languages, many kinds of entities can be declared several
     * times within a single translation unit. For example, a structure type can
     * be forward-declared (possibly multiple times) and later defined:
     *
     * \code
     * struct X;
     * struct X;
     * struct X {
     *   int member;
     * };
     * \endcode
     *
     * The declarations and the definition of \c X are represented by three
     * different cursors, all of which are declarations of the same underlying
     * entity. One of these cursor is considered the "canonical" cursor, which
     * is effectively the representative for the underlying entity. One can
     * determine if two cursors are declarations of the same underlying entity by
     * comparing their canonical cursors.
     *
     * \returns The canonical cursor for the entity referred to by the given cursor.
     */
    CINDEX_LINKAGE CXCursor clang_getCanonicalCursor(CXCursor);
    
    
    /**
     * \brief If the cursor points to a selector identifier in a objc method or
     * message expression, this returns the selector index.
     *
     * After getting a cursor with #clang_getCursor, this can be called to
     * determine if the location points to a selector identifier.
     *
     * \returns The selector index if the cursor is an objc method or message
     * expression and the cursor is pointing to a selector identifier, or -1
     * otherwise.
     */
    CINDEX_LINKAGE int clang_Cursor_getObjCSelectorIndex(CXCursor);
    
    /**
     * \brief Given a cursor pointing to a C++ method call or an ObjC message,
     * returns non-zero if the method/message is "dynamic", meaning:
     *
     * For a C++ method: the call is virtual.
     * For an ObjC message: the receiver is an object instance, not 'super' or a
     * specific class.
     * 
     * If the method/message is "static" or the cursor does not point to a
     * method/message, it will return zero.
     */
    CINDEX_LINKAGE int clang_Cursor_isDynamicCall(CXCursor C);
    
    /**
     * \brief Given a cursor pointing to an ObjC message, returns the CXType of the
     * receiver.
     */
    CINDEX_LINKAGE CXType clang_Cursor_getReceiverType(CXCursor C);
    
    /**
     * \brief Given a cursor that represents a property declaration, return the
     * associated property attributes. The bits are formed from
     * \c CXObjCPropertyAttrKind.
     *
     * \param reserved Reserved for future use, pass 0.
     */
    CINDEX_LINKAGE unsigned clang_Cursor_getObjCPropertyAttributes(CXCursor C,
                                                                   unsigned reserved);
    
    
    /**
     * \brief Given a cursor that represents an ObjC method or parameter
     * declaration, return the associated ObjC qualifiers for the return type or the
     * parameter respectively. The bits are formed from CXObjCDeclQualifierKind.
     */
    CINDEX_LINKAGE unsigned clang_Cursor_getObjCDeclQualifiers(CXCursor C);
    
    /**
     * \brief Given a cursor that represents an ObjC method or property declaration,
     * return non-zero if the declaration was affected by "@optional".
     * Returns zero if the cursor is not such a declaration or it is "@required".
     */
    CINDEX_LINKAGE unsigned clang_Cursor_isObjCOptional(CXCursor C);
    
    /**
     * \brief Returns non-zero if the given cursor is a variadic function or method.
     */
    CINDEX_LINKAGE unsigned clang_Cursor_isVariadic(CXCursor C);
    
    /**
     * \brief Given a cursor that represents a declaration, return the associated
     * comment's source range.  The range may include multiple consecutive comments
     * with whitespace in between.
     */
    CINDEX_LINKAGE CXSourceRange clang_Cursor_getCommentRange(CXCursor C);
    
    /**
     * \brief Given a cursor that represents a declaration, return the associated
     * comment text, including comment markers.
     */
    CINDEX_LINKAGE CXString clang_Cursor_getRawCommentText(CXCursor C);
    
    /**
     * \brief Given a cursor that represents a documentable entity (e.g.,
     * declaration), return the associated \\brief paragraph; otherwise return the
     * first paragraph.
     */
    CINDEX_LINKAGE CXString clang_Cursor_getBriefCommentText(CXCursor C);
    
    /**
     * \brief Given a cursor that represents a documentable entity (e.g.,
     * declaration), return the associated parsed comment as a
     * \c CXComment_FullComment AST node.
     */
    CINDEX_LINKAGE CXComment clang_Cursor_getParsedComment(CXCursor C);
    
    /**
     * @}
     */
    
    

}

@end