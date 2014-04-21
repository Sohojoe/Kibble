//
//  KTClassRnD.h
//  Kibble
//
//  Created by Joe on 3/15/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KTClassProtocol <NSObject>
-(NSString*)name;
@optional
@end

@interface KTClassRnD : NSObject <KTClassProtocol>
@property (nonatomic, strong) NSString* name;
+(void)test;
@end

@class KTClass;
@interface KTFoundation : NSObject <KTClassProtocol, NSCoding>
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSMutableDictionary* classes;
+(KTFoundation*)foundationWithName:(NSString *)name;
+(void)enumerateFoundations:(void(^)(KTFoundation* aFoundation))block;
-(void)addClass:(KTClass*)aClass;


-(KTClass*)classWithName:(NSString*)aName;

-(void)enumerateClasses:(void(^)(KTClass* aClass))block;
-(void)enumerateClassesInOrder:(void(^)(KTClass* aClass))block;
-(void)saveToiOSDisk;
-(void)saveToOSXDisk;
+(KTFoundation*)foundationFromDisk:(NSString *)name;
@property (nonatomic, strong) NSMutableArray *classesTemp;
@end


@class KTMethod;
@class KTVariable;
@interface KTClass : NSObject <KTClassProtocol, NSCoding>
@property (nonatomic, strong) NSString* name;
/**
 * Create a KTclass with this name
 * Will search to see if the class exists, if it does it will return that class, otherwise it will create and return a new class
 * @param aName the name to of the class
 * @return KTClass the class instance
 */
+(KTClass*)classWithName:(NSString*)name;

/**
 * finds and returns the KTclass with this name
 * @param aName the name to search for
 * @return KTClass the class or nil if no class
 */
+(KTClass*)findClassWithName:(NSString*)aName;
/**
 * Finds and returns the KTclass from this object
 * NB: will recruse on super class if nothing found
 * @param anObject the object to search from
 * @return KTClass the class or nil if no class
 */
+(KTClass*)findClassOfObject:(id)anObject;

-(void)addClassMethod:(KTMethod*)aMethod;
-(void)addInstanceMethod:(KTMethod*)aMethod;
-(void)enumerateClassIniters:(void(^)(KTMethod* aMethod))block;
-(void)enumerateInterface:(void(^)(KTMethod* aClassMethod, KTMethod* anIntanceMethod,KTVariable* anInstanceVariable))block;
-(void)enumerateClassMethods:(void(^)(KTMethod* aMethod))block;
-(void)enumerateInstanceMethods:(void(^)(KTMethod* aMethod))block;
-(void)enumerateInstanceVars:(void(^)(KTVariable* aVariable))block;
//+(id)sendMessageToClass:(KTClass*)aClass message:(NSString*)aMessage params:(id)params, ...;
-(id)callMethod:(KTMethod*)aMethod params:(NSArray*)params;
-(KTMethod*)classMethodWithName:(NSString*)name;
-(KTMethod*)instanceMethodWithName:(NSString*)name;
@property (nonatomic, strong) NSMutableDictionary* classMethods;
@property (nonatomic, strong) NSMutableDictionary* classVars;
@property (nonatomic, strong) NSMutableDictionary* instanceMethods;
@property (nonatomic, strong) NSMutableDictionary* instanceVars;
@property (nonatomic, strong) NSMutableArray* methodsTemp;
//protocols
//catagories
@end



@class KTType;
@interface KTMethodParam : NSObject <KTClassProtocol, NSCoding>
/// method name
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSString* paramName;
@property (nonatomic, strong) KTType* paramType;
+(KTMethodParam*) newParam:(NSString*)paramName paramType:(KTType*)type;
+(KTMethodParam*) newParam:(NSString*)paramName paramType:(KTType*)type commandName:(NSString*)commandName;
+(KTMethodParam*) newParam:(NSString*)paramName paramType:(KTType*)type commandName:(NSString*)commandName comment:(NSString*)comment;
@end

@interface KTMethod : NSObject <KTClassProtocol>
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) KTType* returns;
@property (nonatomic) BOOL isClass;
@property (nonatomic) BOOL isInstance;
@property (nonatomic, strong) NSArray *params;
+(KTMethod*)classMethodWithReturns:(KTType*)returns methodName:(NSString*)methodName params:(NSArray*)params comment:(NSString*)comment;
+(KTMethod*)instanceMethodWithReturns:(KTType*)returns methodName:(NSString*)methodName params:(NSArray*)params comment:(NSString*)comment;
@end

@interface KTVariable : NSObject <KTClassProtocol, NSCoding>
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic) BOOL isClass;
@property (nonatomic) BOOL isInstance;
@property (nonatomic) BOOL isReadOnly;
@property (nonatomic, weak) KTMethod *getter;
@property (nonatomic, weak) KTMethod *setter;
@end


/**
 * \brief Describes the kind of type
 */
enum KTCXTypeKind {
    /**
     * \brief Reprents an invalid type (e.g., where no type is available).
     */
    KTCXType_Invalid = 0,
    
    /**
     * \brief A type whose specific kind is not exposed via this
     * interface.
     */
    KTCXType_Unexposed = 1,
    
    /* Builtin types */
    KTCXType_Void = 2,
    KTCXType_Bool = 3,
    KTCXType_Char_U = 4,
    KTCXType_UChar = 5,
    KTCXType_Char16 = 6,
    KTCXType_Char32 = 7,
    KTCXType_UShort = 8,
    KTCXType_UInt = 9,
    KTCXType_ULong = 10,
    KTCXType_ULongLong = 11,
    KTCXType_UInt128 = 12,
    KTCXType_Char_S = 13,
    KTCXType_SChar = 14,
    KTCXType_WChar = 15,
    KTCXType_Short = 16,
    KTCXType_Int = 17,
    KTCXType_Long = 18,
    KTCXType_LongLong = 19,
    KTCXType_Int128 = 20,
    KTCXType_Float = 21,
    KTCXType_Double = 22,
    KTCXType_LongDouble = 23,
    KTCXType_NullPtr = 24,
    KTCXType_Overload = 25,
    KTCXType_Dependent = 26,
    KTCXType_ObjCId = 27,
    KTCXType_ObjCClass = 28,
    KTCXType_ObjCSel = 29,
    KTCXType_FirstBuiltin = KTCXType_Void,
    KTCXType_LastBuiltin  = KTCXType_ObjCSel,
    
    KTCXType_Complex = 100,
    KTCXType_Pointer = 101,
    KTCXType_BlockPointer = 102,
    KTCXType_LValueReference = 103,
    KTCXType_RValueReference = 104,
    KTCXType_Record = 105,
    KTCXType_Enum = 106,
    KTCXType_Typedef = 107,
    KTCXType_ObjCInterface = 108,
    KTCXType_ObjCObjectPointer = 109,
    KTCXType_FunctionNoProto = 110,
    KTCXType_FunctionProto = 111,
    KTCXType_ConstantArray = 112,
    KTCXType_Vector = 113,
    KTCXType_IncompleteArray = 114,
    KTCXType_VariableArray = 115,
    KTCXType_DependentSizedArray = 116,
    KTCXType_MemberPointer = 117
};
@interface KTType : NSObject <NSCoding>
+(KTType*)objCInterface:(NSString*)thisName;
+(KTType*)objCObjectPointer:(NSString*)thisName;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *kindAsText;
@property (nonatomic) enum KTCXTypeKind kind;
/**
 * \brief Return the canonical type.
 *
 * Clang's type system explicitly models typedefs and all the ways
 * a specific type can be represented.  The canonical type is the underlying
 * type with all the "sugar" removed.  For example, if 'T' is a typedef
 * for 'int', the canonical type for 'T' would be 'int'.
 */
@property (nonatomic) KTType *canonical;
/**
 * \brief For pointer types, returns the type of the pointee.
 */
@property (nonatomic) KTType *pointee;
/**
 * \brief Determine whether a CXType has the "const" qualifier set,
 * without looking through typedefs that may have added "const" at a
 * different level.
 */
@property (nonatomic) BOOL isConstQualified;
/**
 * \brief Determine whether a CXType has the "volatile" qualifier set,
 * without looking through typedefs that may have added "volatile" at
 * a different level.
 */
@property (nonatomic) BOOL isVolatileQualified;
/**
 * \brief Determine whether a CXType has the "restrict" qualifier set,
 * without looking through typedefs that may have added "restrict" at a
 * different level.
 */
@property (nonatomic) BOOL isRestrictQualified;
/**
 * \brief Returns non-zero if the given cursor is a variadic function or method.
 */
@property (nonatomic) BOOL isVariadic;
/**
 * \brief Return YES if the CXType is a POD (plain old data) type, and 0
 *  otherwise.
 */
@property (nonatomic) BOOL isPODType;


//ADD THESE TO THE CODING!!!!

/**
 * \brief Return the size of a type in bytes as per C++[expr.sizeof] standard.
 *
 * If the type declaration is invalid, -1 (CXTypeLayoutError_Invalid) is returned.
 * If the type declaration is an incomplete type, -2 (CXTypeLayoutError_Incomplete)
 *   is returned.
 * If the type declaration is a dependent type, -3 (CXTypeLayoutError_Dependent) is
 *   returned.
 */
@property (nonatomic) NSInteger sizeOf;

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
@property (nonatomic) NSInteger alignOf;

/**
 * \brief Retrieve the return type associated with a function type.
 *
 * If a non-function type is passed in, an invalid type is returned.
 */
@property (nonatomic) KTType *resultType;

/**
 * \brief Retrieve the number of non-variadic parameters associated with a
 * function type.
 *
 * If a non-function type is passed in, -1 is returned.
 */
@property (nonatomic) NSInteger numArgTypes;


/**
 * \brief Return YES if the CXType is a c type, otherwise NO
 *
 * If NO then it is an ObjC type
 */
@property (nonatomic, readonly) BOOL isCType;
-(NSValue*)nillValue;
-(NSValue*)valueFromNumber:(NSNumber*)aNumber;


@end

