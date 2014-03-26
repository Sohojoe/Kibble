//
//  CXTypeObjC.m
//  ObjectiveBrowser
//
//  Created by Joe on 3/8/14.
//
//

#import "CXTypeObjC.h"
#import "CXTypeObjC+Private.h"
#import <clang-c/Index.h>
#import "CXCursorObjC.h"
#import "CXCursorObjC+Private.h"


@interface CXTypeObjC()
@property (nonatomic) CXType type;
@end


@implementation CXTypeObjC
@synthesize rawKind;
-(NSInteger)rawKind{
    NSInteger raw = self.type.kind;
    return raw;
}

+(CXTypeObjC *)typeFromPointer:(void *) ptrToThisType{
    CXType *thisType = ptrToThisType;
    return [CXTypeObjC typeFrom:*thisType];
}

@synthesize alignOf, arrayElementType, arraySize, canonicalType, classType, cXXRefQualifier, cXXRefQualifierDescription, elementType, functionTypeCallingConv, functionTypeCallingConvDescription, isConstQualifiedType, isFunctionTypeVariadic, isPODType, isRestrictQualifiedType, isVolatileQualifiedType, numArgTypes, numElements, pointeeType, resultType, sizeOf, typeDeclaration,typeKindSpelling,typeSpelling;

-(CXTypeObjC*)canonicalType{
//CINDEX_LINKAGE CXType clang_getCanonicalType(CXType T);
    CXType tRaw= clang_getCanonicalType(self.type);
    CXTypeObjC* t = [CXTypeObjC typeFrom:tRaw];
    return t;
}

-(BOOL)isConstQualifiedType{
//CINDEX_LINKAGE unsigned clang_isConstQualifiedType(CXType T);
    BOOL b = (BOOL)clang_isConstQualifiedType(self.type);
    return b;
}

-(BOOL)isVolatileQualifiedType{
//CINDEX_LINKAGE unsigned clang_isVolatileQualifiedType(CXType T);
    BOOL b = (BOOL)clang_isVolatileQualifiedType(self.type);
    return b;
}

-(BOOL)isRestrictQualifiedType{
//CINDEX_LINKAGE unsigned clang_isRestrictQualifiedType(CXType T);
    BOOL b = (BOOL)clang_isRestrictQualifiedType(self.type);
    return b;
}
    
-(CXTypeObjC*)pointeeType{
//CINDEX_LINKAGE CXType clang_getPointeeType(CXType T);
    CXType tRaw= clang_getPointeeType(self.type);
    CXTypeObjC* t = [CXTypeObjC typeFrom:tRaw];
    return t;
}
    
-(CXCursorObjC*)typeDeclaration{
//CINDEX_LINKAGE CXCursor clang_getTypeDeclaration(CXType T);
    CXCursor cRaw= clang_getTypeDeclaration(self.type);
    CXCursorObjC* c = [CXCursorObjC cursorFrom:cRaw];
    return c;
}
    
-(NSString*)functionTypeCallingConvDescription{
    return [NSString stringWithFormat:@"%lu", (unsigned long)self.typeDeclaration];
}

-(NSUInteger)functionTypeCallingConv{
//CINDEX_LINKAGE enum CXCallingConv clang_getFunctionTypeCallingConv(CXType T);
    NSUInteger ui = (NSUInteger)clang_getFunctionTypeCallingConv(self.type);
    return ui;
}

-(CXTypeObjC*)resultType{
//CINDEX_LINKAGE CXType clang_getResultType(CXType T);
    CXType tRaw= clang_getResultType(self.type);
    CXTypeObjC* t = [CXTypeObjC typeFrom:tRaw];
    return t;
}

-(NSInteger)numArgTypes{
//CINDEX_LINKAGE int clang_getNumArgTypes(CXType T);
    NSInteger i = (NSInteger)clang_getNumArgTypes(self.type);
    return i;
}
-(CXTypeObjC*)argType:(NSUInteger)forIndex{
//CINDEX_LINKAGE CXType clang_getArgType(CXType T, unsigned i);
    CXType tRaw= clang_getArgType(self.type, (unsigned)forIndex);
    CXTypeObjC* t = [CXTypeObjC typeFrom:tRaw];
    return t;
}
-(NSUInteger)isFunctionTypeVariadic{
//CINDEX_LINKAGE unsigned clang_isFunctionTypeVariadic(CXType T);
    NSUInteger ui = (NSUInteger)clang_isFunctionTypeVariadic(self.type);
    return ui;
}
-(BOOL)isPODType{
//CINDEX_LINKAGE unsigned clang_isPODType(CXType T);
    BOOL b = (BOOL)clang_isPODType(self.type);
    return b;
}
-(CXTypeObjC*)elementType{
//CINDEX_LINKAGE CXType clang_getElementType(CXType T);
    CXType tRaw= clang_getElementType(self.type);
    CXTypeObjC* t = [CXTypeObjC typeFrom:tRaw];
    return t;
}
-(long long)numElements{
//CINDEX_LINKAGE long long clang_getNumElements(CXType T);
    long long ll = (long long)clang_getNumElements(self.type);
    return ll;
}
-(CXTypeObjC*)arrayElementType{
//CINDEX_LINKAGE CXType clang_getArrayElementType(CXType T);
    CXType tRaw= clang_getArrayElementType(self.type);
    CXTypeObjC* t = [CXTypeObjC typeFrom:tRaw];
    return t;
}
-(long long)arraySize{
//CINDEX_LINKAGE long long clang_getArraySize(CXType T);
    long long ll = (long long)clang_getArraySize(self.type);
    return ll;
}
-(NSInteger)alignOf{
//CINDEX_LINKAGE long long clang_Type_getAlignOf(CXType T);
    NSInteger i = (NSInteger)clang_Type_getAlignOf(self.type);
    return i;
}
-(CXTypeObjC*)classType{
//CINDEX_LINKAGE CXType clang_Type_getClassType(CXType T);
    CXType tRaw= clang_Type_getClassType(self.type);
    CXTypeObjC* t = [CXTypeObjC typeFrom:tRaw];
    return t;
}
-(NSInteger)sizeOf{
//CINDEX_LINKAGE long long clang_Type_getSizeOf(CXType T);
    NSInteger i = (NSInteger)clang_Type_getSizeOf(self.type);
    return i;
}
-(long long)offsetOf:(const char*)string{
//CINDEX_LINKAGE long long clang_Type_getOffsetOf(CXType T, const char *S);
    long long ll = (long long)clang_Type_getOffsetOf(self.type, string);
    return ll;
}

-(NSUInteger)cXXRefQualifier{
//CINDEX_LINKAGE enum CXRefQualifierKind clang_Type_getCXXRefQualifier(CXType T);
    NSUInteger ui = (NSUInteger)clang_Type_getCXXRefQualifier(self.type);
    return ui;
}
-(NSString*)cXXRefQualifierDescription{
    return [NSString stringWithFormat:@"%lu", (unsigned long)self.cXXRefQualifier];
}

-(NSString*)typeSpelling{
//CINDEX_LINKAGE CXString clang_getTypeSpelling(CXType CT);
    const char *cstr = clang_getCString(clang_getTypeSpelling(self.type));
    if (cstr) {
        NSString *str = [NSString stringWithUTF8String:cstr];
        return str;
    } else {
        return (@"");
    }}
-(NSString*)typeKindSpelling{
//CINDEX_LINKAGE CXString clang_getTypeKindSpelling(enum CXTypeKind K);
    const char *cstr = clang_getCString(clang_getTypeKindSpelling(self.type.kind));
    if (cstr) {
        NSString *str = [NSString stringWithUTF8String:cstr];
        return str;
    } else {
        return (@"");
    }}


//-----------------------------------------------------------------------------------
-(NSString*)description{
    return self.typeSpelling;
}

-(NSString*)debugDescription{
    NSMutableString* output = [NSMutableString new];

    //NSString *lnk = @"; ";
    NSString *lnk = @"\n";

    [output appendFormat:@"typeSpelling = %@", self.typeSpelling];

    [output appendString:lnk];
    [output appendFormat:@"typeKindSpelling = %@", self.typeKindSpelling];

    [output appendString:lnk];
    [output appendFormat:@"canonicalType = %@", self.canonicalType];
    //CINDEX_LINKAGE CXType clang_getCanonicalType(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"isConstQualifiedType = %hhd", self.isConstQualifiedType];
    //CINDEX_LINKAGE unsigned clang_isConstQualifiedType(CXType T);


    [output appendString:lnk];
    [output appendFormat:@"isVolatileQualifiedType = %hhd", self.isVolatileQualifiedType];
    //CINDEX_LINKAGE unsigned clang_isVolatileQualifiedType(CXType T);


    [output appendString:lnk];
    [output appendFormat:@"isRestrictQualifiedType = %hhd", self.isRestrictQualifiedType];
    //CINDEX_LINKAGE unsigned clang_isRestrictQualifiedType(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"pointeeType = %@", self.pointeeType];
    //CINDEX_LINKAGE CXType clang_getPointeeType(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"typeDeclaration = %@", self.typeDeclaration];
    //CINDEX_LINKAGE CXCursor clang_getTypeDeclaration(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"functionTypeCallingConvDescription = %@", self.functionTypeCallingConvDescription];

    [output appendString:lnk];
    [output appendFormat:@"functionTypeCallingConv = %lu", (unsigned long)self.functionTypeCallingConv];
    //CINDEX_LINKAGE enum CXCallingConv clang_getFunctionTypeCallingConv(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"resultType = %@", self.resultType];
    //CINDEX_LINKAGE CXType clang_getResultType(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"numArgTypes = %ld", (long)self.numArgTypes];
    //CINDEX_LINKAGE int clang_getNumArgTypes(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"forIndex = %@", [self argType:0]];
    //CINDEX_LINKAGE CXType clang_getArgType(CXType T, unsigned i);

    [output appendString:lnk];
    [output appendFormat:@"isFunctionTypeVariadic = %lu", (unsigned long)self.isFunctionTypeVariadic];
    //CINDEX_LINKAGE unsigned clang_isFunctionTypeVariadic(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"isPODType = %hhd", self.isPODType];
    //CINDEX_LINKAGE unsigned clang_isPODType(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"elementType = %@", self.elementType];
    //CINDEX_LINKAGE CXType clang_getElementType(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"numElements = %lld", self.numElements];
    //CINDEX_LINKAGE long long clang_getNumElements(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"arrayElementType = %@", self.arrayElementType];
    //CINDEX_LINKAGE CXType clang_getArrayElementType(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"arraySize = %lld", self.arraySize];
    //CINDEX_LINKAGE long long clang_getArraySize(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"alignOf = %lld", self.alignOf];
    //CINDEX_LINKAGE long long clang_Type_getAlignOf(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"classType = %@", self.classType];
    //CINDEX_LINKAGE CXType clang_Type_getClassType(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"sizeOf = %lld", self.sizeOf];
    //CINDEX_LINKAGE long long clang_Type_getSizeOf(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"offsetOf = %lld", [self offsetOf:[@" " UTF8String]]];
     //CINDEX_LINKAGE long long clang_Type_getOffsetOf(CXType T, const char *S);

    [output appendString:lnk];
    [output appendFormat:@"cXXRefQualifier = %lu", (unsigned long)self.cXXRefQualifier];
     //CINDEX_LINKAGE enum CXRefQualifierKind clang_Type_getCXXRefQualifier(CXType T);

    [output appendString:lnk];
    [output appendFormat:@"cXXRefQualifierDescription = %@", self.cXXRefQualifierDescription];

    return (output);
}


@end
