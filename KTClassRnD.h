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
@property (nonatomic, strong) NSMutableArray* classes;
+(KTFoundation*)foundationWithName:(NSString *)name;
-(void)addClass:(KTClass*)aClass;
-(void)enumerateClasses:(void(^)(KTClass* aClass))block;
-(void)saveToDisk;
+(KTFoundation*)foundationFromDisk:(NSString *)name;
@end


@class KTMethod;
@interface KTClass : NSObject <KTClassProtocol, NSCoding>
@property (nonatomic, strong) NSString* name;
+(KTClass*)classWithName:(NSString*)name;
-(void)addClassMethod:(KTMethod*)aMethod;
-(void)addInstanceMethod:(KTMethod*)aMethod;
-(void)enumerateClassIniters:(void(^)(KTMethod* aMethod))block;
+(id)sendMessageToClass:(KTClass*)aClass message:(NSString*)aMessage params:(id)params, ...;
@property (nonatomic, strong) NSMutableArray* classMethods;
@property (nonatomic, strong) NSMutableArray* classVars;
@property (nonatomic, strong) NSMutableArray* instanceMethods;
@property (nonatomic, strong) NSMutableArray* instanceVars;
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
enum CXTypeKind {
    /**
     * \brief Reprents an invalid type (e.g., where no type is available).
     */
    CXType_Invalid = 0,
    
    /**
     * \brief A type whose specific kind is not exposed via this
     * interface.
     */
    CXType_Unexposed = 1,
    
    /* Builtin types */
    CXType_Void = 2,
    CXType_Bool = 3,
    CXType_Char_U = 4,
    CXType_UChar = 5,
    CXType_Char16 = 6,
    CXType_Char32 = 7,
    CXType_UShort = 8,
    CXType_UInt = 9,
    CXType_ULong = 10,
    CXType_ULongLong = 11,
    CXType_UInt128 = 12,
    CXType_Char_S = 13,
    CXType_SChar = 14,
    CXType_WChar = 15,
    CXType_Short = 16,
    CXType_Int = 17,
    CXType_Long = 18,
    CXType_LongLong = 19,
    CXType_Int128 = 20,
    CXType_Float = 21,
    CXType_Double = 22,
    CXType_LongDouble = 23,
    CXType_NullPtr = 24,
    CXType_Overload = 25,
    CXType_Dependent = 26,
    CXType_ObjCId = 27,
    CXType_ObjCClass = 28,
    CXType_ObjCSel = 29,
    CXType_FirstBuiltin = CXType_Void,
    CXType_LastBuiltin  = CXType_ObjCSel,
    
    CXType_Complex = 100,
    CXType_Pointer = 101,
    CXType_BlockPointer = 102,
    CXType_LValueReference = 103,
    CXType_RValueReference = 104,
    CXType_Record = 105,
    CXType_Enum = 106,
    CXType_Typedef = 107,
    CXType_ObjCInterface = 108,
    CXType_ObjCObjectPointer = 109,
    CXType_FunctionNoProto = 110,
    CXType_FunctionProto = 111,
    CXType_ConstantArray = 112,
    CXType_Vector = 113,
    CXType_IncompleteArray = 114,
    CXType_VariableArray = 115,
    CXType_DependentSizedArray = 116,
    CXType_MemberPointer = 117
};
@interface KTType : NSObject <NSCoding>
+(KTType*)objCInterface:(NSString*)thisName;
+(KTType*)objCObjectPointer:(NSString*)thisName;
@property (nonatomic) NSString *name;

@property (nonatomic) enum CXTypeKind kind;
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
//@property (nonatomic, readonly) BOOL isConstQualified;
/**
 * \brief Determine whether a CXType has the "volatile" qualifier set,
 * without looking through typedefs that may have added "volatile" at
 * a different level.
 */
//@property (nonatomic, readonly) BOOL isVolatileQualified;
/**
 * \brief Determine whether a CXType has the "restrict" qualifier set,
 * without looking through typedefs that may have added "restrict" at a
 * different level.
 */
//@property (nonatomic, readonly) BOOL isRestrictQualified;
/**
 * \brief Returns non-zero if the given cursor is a variadic function or method.
 */
//@property (nonatomic, readonly) BOOL isVariadic;
/**
 * \brief Return YES if the CXType is a POD (plain old data) type, and 0
 *  otherwise.
 */
//@property (nonatomic, readonly) BOOL isPODType;
@end

