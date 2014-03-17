//
//  CXTypeObjC.h
//  ObjectiveBrowser
//
//  Created by Joe on 3/8/14.
//
//

#import <Foundation/Foundation.h>

@class CXCursorObjC;

@interface CXTypeObjC : NSObject

///Return the CXType Kind without any typedef
@property (nonatomic, readonly) NSInteger rawKind;

/**
 * \brief Return the canonical type for a CXType.
 *
 * Clang's type system explicitly models typedefs and all the ways
 * a specific type can be represented.  The canonical type is the underlying
 * type with all the "sugar" removed.  For example, if 'T' is a typedef
 * for 'int', the canonical type for 'T' would be 'int'.
 */
@property (nonatomic, readonly, strong) CXTypeObjC* canonicalType;
//CINDEX_LINKAGE CXType clang_getCanonicalType(CXType T);

/**
 * \brief Determine whether a CXType has the "const" qualifier set,
 * without looking through typedefs that may have added "const" at a
 * different level.
 */
@property (nonatomic, readonly) BOOL isConstQualifiedType;
//CINDEX_LINKAGE unsigned clang_isConstQualifiedType(CXType T);

/**
 * \brief Determine whether a CXType has the "volatile" qualifier set,
 * without looking through typedefs that may have added "volatile" at
 * a different level.
 */
@property (nonatomic, readonly) BOOL isVolatileQualifiedType;
//CINDEX_LINKAGE unsigned clang_isVolatileQualifiedType(CXType T);

/**
 * \brief Determine whether a CXType has the "restrict" qualifier set,
 * without looking through typedefs that may have added "restrict" at a
 * different level.
 */
@property (nonatomic, readonly) BOOL isRestrictQualifiedType;
//CINDEX_LINKAGE unsigned clang_isRestrictQualifiedType(CXType T);

/**
 * \brief For pointer types, returns the type of the pointee.
 */
@property (nonatomic, readonly, strong) CXTypeObjC* pointeeType;
//CINDEX_LINKAGE CXType clang_getPointeeType(CXType T);

/**
 * \brief Return the cursor for the declaration of the given type.
 */
@property (nonatomic, readonly, strong) CXCursorObjC* typeDeclaration;
//CINDEX_LINKAGE CXCursor clang_getTypeDeclaration(CXType T);

/**
 * \brief Retrieve the calling convention associated with a function type.
 *
 * If a non-function type is passed in, CXCallingConv_Invalid is returned.
 */
@property (nonatomic, readonly, strong) NSString *functionTypeCallingConvDescription;

/**
 * \brief Retrieve the calling convention associated with a function type.
 *
 * If a non-function type is passed in, CXCallingConv_Invalid is returned.
 */
@property (nonatomic, readonly) NSUInteger functionTypeCallingConv;
//CINDEX_LINKAGE enum CXCallingConv clang_getFunctionTypeCallingConv(CXType T);

/**
 * \brief Retrieve the return type associated with a function type.
 *
 * If a non-function type is passed in, an invalid type is returned.
 */
@property (nonatomic, readonly, strong) CXTypeObjC *resultType;
//CINDEX_LINKAGE CXType clang_getResultType(CXType T);

/**
 * \brief Retrieve the number of non-variadic parameters associated with a
 * function type.
 *
 * If a non-function type is passed in, -1 is returned.
 */
@property (nonatomic, readonly) NSInteger numArgTypes;
//CINDEX_LINKAGE int clang_getNumArgTypes(CXType T);

/**
 * \brief Retrieve the type of a parameter of a function type.
 *
 * If a non-function type is passed in or the function does not have enough
 * parameters, an invalid type is returned.
 */
-(CXTypeObjC*)argType:(NSUInteger)forIndex;
//CINDEX_LINKAGE CXType clang_getArgType(CXType T, unsigned i);

/**
 * \brief Return 1 if the CXType is a variadic function type, and 0 otherwise.
 */
@property (nonatomic, readonly) NSUInteger isFunctionTypeVariadic;
//CINDEX_LINKAGE unsigned clang_isFunctionTypeVariadic(CXType T);

/**
 * \brief Return 1 if the CXType is a POD (plain old data) type, and 0
 *  otherwise.
 */
@property (nonatomic, readonly) BOOL isPODType;
//CINDEX_LINKAGE unsigned clang_isPODType(CXType T);

/**
 * \brief Return the element type of an array, complex, or vector type.
 *
 * If a type is passed in that is not an array, complex, or vector type,
 * an invalid type is returned.
 */
@property (nonatomic, readonly, strong) CXTypeObjC* elementType;
//CINDEX_LINKAGE CXType clang_getElementType(CXType T);

/**
 * \brief Return the number of elements of an array or vector type.
 *
 * If a type is passed in that is not an array or vector type,
 * -1 is returned.
 */
@property (nonatomic, readonly) long long numElements;
//CINDEX_LINKAGE long long clang_getNumElements(CXType T);

/**
 * \brief Return the element type of an array type.
 *
 * If a non-array type is passed in, an invalid type is returned.
 */
@property (nonatomic, readonly, strong) CXTypeObjC* arrayElementType;
//CINDEX_LINKAGE CXType clang_getArrayElementType(CXType T);

/**
 * \brief Return the array size of a constant array.
 *
 * If a non-array type is passed in, -1 is returned.
 */
@property (nonatomic, readonly) long long arraySize;
//CINDEX_LINKAGE long long clang_getArraySize(CXType T);

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
@property (nonatomic, readonly) long long alignOf;
//CINDEX_LINKAGE long long clang_Type_getAlignOf(CXType T);

/**
 * \brief Return the class type of an member pointer type.
 *
 * If a non-member-pointer type is passed in, an invalid type is returned.
 */
@property (nonatomic, readonly, strong) CXTypeObjC* classType;
//CINDEX_LINKAGE CXType clang_Type_getClassType(CXType T);

/**
 * \brief Return the size of a type in bytes as per C++[expr.sizeof] standard.
 *
 * If the type declaration is invalid, CXTypeLayoutError_Invalid is returned.
 * If the type declaration is an incomplete type, CXTypeLayoutError_Incomplete
 *   is returned.
 * If the type declaration is a dependent type, CXTypeLayoutError_Dependent is
 *   returned.
 */
@property (nonatomic, readonly) long long sizeOf;
//CINDEX_LINKAGE long long clang_Type_getSizeOf(CXType T);

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
-(long long) offsetOf:(const char*)string;
//CINDEX_LINKAGE long long clang_Type_getOffsetOf(CXType T, const char *S);


/**
 * \brief Retrieve the ref-qualifier kind of a function or method.
 *
 * The ref-qualifier is returned for C++ functions or methods. For other types
 * or non-C++ declarations, CXRefQualifier_None is returned.
 */
@property (nonatomic, readonly) NSUInteger cXXRefQualifier;
//CINDEX_LINKAGE enum CXRefQualifierKind clang_Type_getCXXRefQualifier(CXType T);

/**
 * \brief Retrieve the ref-qualifier kind of a function or method.
 *
 * The ref-qualifier is returned for C++ functions or methods. For other types
 * or non-C++ declarations, CXRefQualifier_None is returned.
 */
@property (nonatomic, readonly, strong) NSString *cXXRefQualifierDescription;

/**
 * \brief Pretty-print the underlying type using the rules of the
 * language of the translation unit from which it came.
 *
 * If the type is invalid, an empty string is returned.
 */
@property (nonatomic, readonly, strong) NSString *typeSpelling;
//CINDEX_LINKAGE CXString clang_getTypeSpelling(CXType CT);

/**
 * \brief Retrieve the spelling of a given CXTypeKind.
 */
@property (nonatomic, readonly, strong) NSString *typeKindSpelling;
//CINDEX_LINKAGE CXString clang_getTypeKindSpelling(enum CXTypeKind K);


@end
