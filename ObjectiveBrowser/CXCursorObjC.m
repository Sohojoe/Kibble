//
//  CXCursorObjC.m
//  ObjectiveBrowser
//
//  Created by Joe on 3/6/14.
//
//

#import "CXCursorObjC.h"
#import <clang-c/Index.h>
#import "CXCursorObjC+Private.h"
#import "CXTypeObjC+Private.h"
#import "CXCommentObjC+Private.h"


@interface CXCursorObjC ()
@property (nonatomic) CXCursor cursor;
@end

@implementation CXCursorObjC
@synthesize briefCommentText, cursorAvailability, canonicalCursor, cursorDefinition, cursorDisplayName, cursorKind, cursorLexicalParent, cursorReferenced, cursorResultType, cursorSemanticParent, cursorType, cursorUSR, declObjCTypeEncoding, enumConstantDeclUnsignedValue, enumConstantDeclValue, enumDeclIntegerType, receiverType, isNull, includedFile, isBitField, isCursorDefinition, isDynamicCall, isObjCOptional, isPureVirtual, isStatic, isVariadic, isVirtual, isVirtualBase, numArguments, objCDeclQualifiers, objCSelectorIndex, rawCommentText, specializedCursorTemplate, typedefDeclUnderlyingType, cursorSpelling, parsedComment;

@synthesize cursor;

+(CXCursorObjC *)cursorFromPointer:(void *) ptrToThisCursor{
    CXCursor *thisCursor = ptrToThisCursor;
    return [CXCursorObjC cursorFrom:*thisCursor];
}
//---------------------------------------------------------------------------------

+(CXCursorObjC *)nullCursor{
    //CINDEX_LINKAGE CXCursor clang_getNullCursor(void);
    return [CXCursorObjC cursorFrom:clang_getNullCursor()];
}

//CINDEX_LINKAGE CXCursor clang_getNullCursor(void);

//CINDEX_LINKAGE CXCursor clang_getTranslationUnitCursor(CXTranslationUnit);

-(BOOL)equalCursors:(CXCursorObjC*) thisCursor{
    //CINDEX_LINKAGE unsigned clang_equalCursors(CXCursor, CXCursor);
    BOOL b = (BOOL) clang_equalCursors(self.cursor, thisCursor.cursor);
    return b;
}

-(BOOL)isNull{
    //CINDEX_LINKAGE int clang_Cursor_isNull(CXCursor cursor);
    BOOL b = (BOOL)clang_Cursor_isNull(self.cursor);
    return b;
}


//@property (nonatomic, readonly) unsigned long *hashCursor;
//CINDEX_LINKAGE unsigned clang_hashCursor(CXCursor);

-(enum CXCursorKind)cursorKind{
    //CINDEX_LINKAGE enum CXCursorKind clang_getCursorKind(CXCursor);
    enum CXCursorKind kind = clang_getCursorKind(self.cursor);
    return kind;
}
            

//CINDEX_LINKAGE enum CXLinkageKind clang_getCursorLinkage(CXCursor cursor);

-(enum CXAvailabilityKind)cursorAvailability {
    //CINDEX_LINKAGE enum CXAvailabilityKind clang_getCursorAvailability(CXCursor cursor);
    enum CXAvailabilityKind ak = clang_getCursorAvailability(self.cursor);
    return ak;
}

//CINDEX_LINKAGE int
//clang_getCursorPlatformAvailability(CXCursor cursor,
//                                    int *always_deprecated,
//                                   CXString *deprecated_message,
//                                   int *always_unavailable,
//                                  CXString *unavailable_message,
//                                 CXPlatformAvailability *availability,
//                                int availability_size);


-(CXCursorObjC*)cursorSemanticParent{
    //CINDEX_LINKAGE CXCursor clang_getCursorSemanticParent(CXCursor cursor);
    CXCursorObjC *c = [CXCursorObjC cursorFrom:clang_getCursorSemanticParent(self.cursor)];
    return c;
}
            

-(CXCursorObjC *)cursorLexicalParent{
    //CINDEX_LINKAGE CXCursor clang_getCursorLexicalParent(CXCursor cursor);
    CXCursorObjC *c = [CXCursorObjC cursorFrom:clang_getCursorLexicalParent(self.cursor)];
    return c;
}

//CINDEX_LINKAGE void clang_getOverriddenCursors(CXCursor cursor,
//                                               CXCursor **overridden,
//                                               unsigned *num_overridden);

//CINDEX_LINKAGE void clang_disposeOverriddenCursors(CXCursor *overridden);

-(CXFileObjC *)includedFile{
    //CINDEX_LINKAGE CXFile clang_getIncludedFile(CXCursor cursor);
    //CXFileObjC *f = [CXFileObjC fileFrom:clang_getIncludedFile(self.cursor)];
    //return f;
    return nil;
}

-(CXTypeObjC *)cursorType{
    //CINDEX_LINKAGE CXType clang_getCursorType(CXCursor C);
    CXTypeObjC *t = [CXTypeObjC typeFrom:clang_getCursorType(self.cursor)];
    return t;
}
            
-(CXTypeObjC *)typedefDeclUnderlyingType{
    //CINDEX_LINKAGE CXType clang_getTypedefDeclUnderlyingType(CXCursor C);
    CXTypeObjC *t = [CXTypeObjC typeFrom:clang_getTypedefDeclUnderlyingType(self.cursor)];
    return t;
}

-(CXTypeObjC *)enumDeclIntegerType{
    //CINDEX_LINKAGE CXType clang_getEnumDeclIntegerType(CXCursor C);
    CXTypeObjC *t = [CXTypeObjC typeFrom:clang_getEnumDeclIntegerType(self.cursor)];
    return t;
}

-(long long)enumConstantDeclValue{
    //CINDEX_LINKAGE long long clang_getEnumConstantDeclValue(CXCursor C);
    long long ll = clang_getEnumConstantDeclUnsignedValue(self.cursor);
    return ll;
}

-(unsigned long long)enumConstantDeclUnsignedValue{
    //CINDEX_LINKAGE unsigned long long clang_getEnumConstantDeclUnsignedValue(CXCursor C);
    unsigned long long ll = clang_getEnumConstantDeclUnsignedValue(self.cursor);
    return ll;
}
//CINDEX_LINKAGE int clang_getFieldDeclBitWidth(CXCursor C);

-(NSInteger)numArguments{
    //CINDEX_LINKAGE int clang_Cursor_getNumArguments(CXCursor C);
    NSInteger i = clang_Cursor_getNumArguments(self.cursor);
    return i;
}

-(CXCursorObjC*) getArgument:(NSUInteger) i{
    //CINDEX_LINKAGE CXCursor clang_Cursor_getArgument(CXCursor C, unsigned i);
    CXCursorObjC *c = [CXCursorObjC cursorFrom:clang_Cursor_getArgument(self.cursor, (unsigned) i)];
    return (c);
}

-(NSString *)declObjCTypeEncoding{
    //CINDEX_LINKAGE CXString clang_getDeclObjCTypeEncoding(CXCursor C);
    const char *cstr = clang_getCString(clang_getDeclObjCTypeEncoding(self.cursor));
    if (cstr) {
        NSString *str = [NSString stringWithUTF8String:cstr];
        return str;
    } else {
        return (@"");
    }
}

-(CXTypeObjC *)cursorResultType{
    //CINDEX_LINKAGE CXType clang_getCursorResultType(CXCursor C);
    CXTypeObjC *t = [CXTypeObjC typeFrom:clang_getCursorResultType(self.cursor)];
    return t;
}


-(BOOL)isBitField{
//CINDEX_LINKAGE unsigned clang_Cursor_isBitField(CXCursor C);
    BOOL b = clang_Cursor_isBitField(self.cursor);
    return b;
}

-(BOOL)isVirtualBase{
    //CINDEX_LINKAGE unsigned clang_isVirtualBase(CXCursor);
    BOOL b = clang_isVirtualBase(self.cursor);
    return b;
}

//CINDEX_LINKAGE enum CX_CXXAccessSpecifier clang_getCXXAccessSpecifier(CXCursor);

//CINDEX_LINKAGE unsigned clang_getNumOverloadedDecls(CXCursor cursor);

//CINDEX_LINKAGE CXCursor clang_getOverloadedDecl(CXCursor cursor,
//                                                unsigned index);

//CINDEX_LINKAGE CXType clang_getIBOutletCollectionType(CXCursor);

//typedef enum CXChildVisitResult (*CXCursorVisitor)(CXCursor cursor,
//CXCursor parent,
//CXClientData client_data);

//CINDEX_LINKAGE unsigned clang_visitChildren(CXCursor parent,
//                                            CXCursorVisitor visitor,
//                                            CXClientData client_data);

-(BOOL)visitChildrenWithBlock:(CXCursorObjCVisitorBlock) block{
    //unsigned clang_visitChildrenWithBlock(CXCursor parent,
    //                                      CXCursorVisitorBlock block);
    BOOL b = clang_visitChildrenWithBlock(self.cursor, ^enum CXChildVisitResult(CXCursor childCursorRaw, CXCursor parentCursorRaw) {
        CXCursorObjC *childCursor= [CXCursorObjC cursorFrom:childCursorRaw];
        if (block) return (block(childCursor, self));
        else {
            // no block, lets break
            return CXChildVisit_Break;
        }
    });
    return b;
}


-(NSString *)cursorUSR{
    //CINDEX_LINKAGE CXString clang_getCursorUSR(CXCursor);
    const char *cstr = clang_getCString(clang_getCursorUSR(self.cursor));
    if (cstr) {
        NSString *str = [NSString stringWithUTF8String:cstr];
        return str;
    } else {
        return (@"");
    }
}

//CINDEX_LINKAGE CXSourceRange clang_Cursor_getSpellingNameRange(CXCursor,
//                                                               unsigned pieceIndex,
//                                                               unsigned options);


-(NSString *)cursorDisplayName{
    //CINDEX_LINKAGE CXString clang_getCursorDisplayName(CXCursor);
    const char *cstr = clang_getCString(clang_getCursorDisplayName(self.cursor));
    if (cstr) {
        NSString *str = [NSString stringWithUTF8String:cstr];
        return str;
    } else {
        return (@"");
    }
}

-(CXCursorObjC *)cursorReferenced{
    //CINDEX_LINKAGE CXCursor clang_getCursorReferenced(CXCursor);
    CXCursorObjC *c = [CXCursorObjC cursorFrom:clang_getCursorReferenced(self.cursor)];
    return (c);
}

-(CXCursorObjC *)cursorDefinition{
//CINDEX_LINKAGE CXCursor clang_getCursorDefinition(CXCursor);
    CXCursorObjC *c = [CXCursorObjC cursorFrom:clang_getCursorDefinition(self.cursor)];
    return (c);
}

-(BOOL)isCursorDefinition{
//CINDEX_LINKAGE unsigned clang_isCursorDefinition(CXCursor);
    BOOL b = clang_isCursorDefinition(self.cursor);
    return b;
}

-(CXCursorObjC *)canonicalCursor{
//CINDEX_LINKAGE CXCursor clang_getCanonicalCursor(CXCursor);
    CXCursorObjC *c = [CXCursorObjC cursorFrom:clang_getCanonicalCursor(self.cursor)];
    return (c);
}

-(NSInteger)objCSelectorIndex{
//CINDEX_LINKAGE int clang_Cursor_getObjCSelectorIndex(CXCursor);
    NSUInteger *i = clang_Cursor_getObjCSelectorIndex(self.cursor);
    return (i);
}

-(BOOL)isDynamicCall{
//CINDEX_LINKAGE int clang_Cursor_isDynamicCall(CXCursor C);
    BOOL b = clang_Cursor_isDynamicCall(self.cursor);
    return b;
}

-(CXTypeObjC *)receiverType{
//CINDEX_LINKAGE CXType clang_Cursor_getReceiverType(CXCursor C);
    CXTypeObjC *t = [CXTypeObjC typeFrom:clang_Cursor_getReceiverType(self.cursor)];
    return (t);
}

-(NSUInteger)objCPropertyAttributes{
//CINDEX_LINKAGE unsigned clang_Cursor_getObjCPropertyAttributes(CXCursor C,
//                                                               unsigned reserved);
    NSUInteger *i = clang_Cursor_getObjCPropertyAttributes(self.cursor, 0);
    return (i);
}

-(NSInteger)objCDeclQualifiers{
//CINDEX_LINKAGE unsigned clang_Cursor_getObjCDeclQualifiers(CXCursor C);
    NSUInteger *i = clang_Cursor_getObjCDeclQualifiers(self.cursor);
    return (i);
}

-(BOOL)isObjCOptional{
//CINDEX_LINKAGE unsigned clang_Cursor_isObjCOptional(CXCursor C);
    BOOL b = clang_Cursor_isObjCOptional(self.cursor);
    return b;
}

-(BOOL)isVariadic{
//CINDEX_LINKAGE unsigned clang_Cursor_isVariadic(CXCursor C);
    BOOL b = clang_Cursor_isVariadic(self.cursor);
    return b;
}

//CINDEX_LINKAGE CXSourceRange clang_Cursor_getCommentRange(CXCursor C);

-(NSString *)rawCommentText{
//CINDEX_LINKAGE CXString clang_Cursor_getRawCommentText(CXCursor C);
    const char *cstr = clang_getCString(clang_Cursor_getRawCommentText(self.cursor));
    if (cstr) {
        NSString *str = [NSString stringWithUTF8String:cstr];
        return str;
    } else {
        return (@"");
    }
}

-(NSString *)briefCommentText{
//CINDEX_LINKAGE CXString clang_Cursor_getBriefCommentText(CXCursor C);
    const char *cstr = clang_getCString(clang_Cursor_getBriefCommentText(self.cursor));
    if (cstr) {
        NSString *str = [NSString stringWithUTF8String:cstr];
        return str;
    } else {
        return (@"");
    }
}
//CINDEX_LINKAGE CXComment clang_Cursor_getParsedComment(CXCursor C);
-(CXCommentObjC *)parsedComment{
    CXCommentObjC *c = [CXCommentObjC commentFrom:clang_Cursor_getParsedComment(self.cursor)];
    return c;
}


//CINDEX_LINKAGE CXModule clang_Cursor_getModule(CXCursor C);

-(BOOL)isPureVirtual{
//CINDEX_LINKAGE unsigned clang_CXXMethod_isPureVirtual(CXCursor C);
    BOOL b = clang_CXXMethod_isPureVirtual(self.cursor);
    return b;
}

-(BOOL)isStatic{
//CINDEX_LINKAGE unsigned clang_CXXMethod_isStatic(CXCursor C);
    BOOL b = clang_CXXMethod_isStatic(self.cursor);
    return b;
}
    
-(BOOL)isVirtual{
//CINDEX_LINKAGE unsigned clang_CXXMethod_isVirtual(CXCursor C);
    BOOL b = clang_CXXMethod_isVirtual(self.cursor);
    return b;
}

//CINDEX_LINKAGE enum CXCursorKind clang_getTemplateCursorKind(CXCursor C);

-(CXCursorObjC *)specializedCursorTemplate{
//CINDEX_LINKAGE CXCursor clang_getSpecializedCursorTemplate(CXCursor C);
    CXCursor cRaw = clang_getSpecializedCursorTemplate(self.cursor);
    CXCursorObjC *c = [CXCursorObjC cursorFrom:cRaw];
    return (c);
}
-(NSString *)cursorSpelling{
    //CINDEX_LINKAGE CXString clang_getCursorSpelling(CXCursor);
    const char *cstr = clang_getCString(clang_getCursorSpelling(self.cursor));
    if (cstr) {
        NSString *str = [NSString stringWithUTF8String:cstr];
        return str;
    } else {
        return (@"");
    }}



//---------------------------------------------------------------------------------
-(void)enumerateMethodDecl:(void (^)(BOOL isClassMethod,
                                     BOOL isIntanceMethod,
                                     NSString *name,
                                     NSString *briefComment,
                                     NSString *rawComment,
                                     NSUInteger numParamaters
                                     ))overviewBlock
                    result:(void (^)(BOOL isVoid,
                                     NSString *returnName
                                     ))resultBlock
                      name:(void (^)(NSString *name,
                                     NSString *briefComment,
                                     NSString *rawComment
                                     ))nameBlock
                 paramater:(void (^)(NSString *paramaterName,
                                     NSString *paramaterType,
                                     NSString *briefComment,
                                     NSString *rawComment
                                     ))paramaterBlock{
    
    // do we need to check that we are a paramater
    
    
    // overview block
    if (overviewBlock) {
        BOOL isClassMethod = (BOOL)self.cursor.kind == CXCursor_ObjCClassMethodDecl;
        BOOL isIntanceMethod = (BOOL)self.cursor.kind == CXCursor_ObjCInstanceMethodDecl;
        //NSString *name = self.cursorDisplayName;
        //NSString*briefCommentText = self.briefCommentText;
        //NSString*rawCommentText = self.rawCommentText;
        //NSUInteger numParamaters = self.numArguments;
        
        
        overviewBlock(isClassMethod,
                      isIntanceMethod,
                      self.cursorDisplayName,
                      self.briefCommentText,
                      self.rawCommentText,
                      self.numArguments);
    }

    // handle return type
    if (resultBlock) {
        // setup as void by default
        BOOL isVoid = YES;
        NSString *returnName = @"void";

        if (self.cursorResultType.type.kind) {
            // has a return type
            isVoid = NO;
            returnName = self.cursorResultType.description;
        }
        resultBlock(isVoid, returnName);
    }
    
    if (nameBlock || paramaterBlock) {
        //name:(void (^)(
        NSString *name;
        
        //paramater:(void (^)(
        NSString *paramaterName;
        NSString *paramaterType;
        NSString *paramaterBriefCommentText = nil;
        NSString *paramaterRawCommentText = nil;
        
        if (self.numArguments == 0) {
            // no paramaters
            name = self.cursorDisplayName;
            if (nameBlock) {
                nameBlock(name, paramaterBriefCommentText, paramaterRawCommentText);
            }
            

        } else {
            NSArray *methodNameByArguments = [self.cursorDisplayName componentsSeparatedByString:@":"];
            // loop paramaters
            for (NSInteger i=0; i<self.numArguments; i++) {
                CXCursorObjC *thisArgument = [self getArgument:i];
                name = [methodNameByArguments objectAtIndex:i];
                paramaterName = thisArgument.description;
                paramaterType = thisArgument.cursorType.description;
                paramaterBriefCommentText = thisArgument.briefCommentText;
                paramaterRawCommentText = thisArgument.rawCommentText;
                NSString *fred = [self.parsedComment commentFor:i];
                
                if (nameBlock) {
                    nameBlock (name, paramaterBriefCommentText, paramaterRawCommentText);
                }
                if (paramaterBlock) {
                    paramaterBlock(paramaterName, paramaterType, paramaterBriefCommentText, paramaterRawCommentText);
                }
            }
        }
    }
}



//---------------------------------------------------------------------------------
-(NSString*)description{
    switch (self.cursor.kind) {
        case CXCursor_ObjCInstanceMethodDecl:
        case CXCursor_ObjCClassMethodDecl:
            return ([self debugDescriptionMethodDecl]);
            break;
        default:
            return self.cursorSpelling;
    }
}
-(NSString*)debugDescription {
    return [self objCStyleDescription];
}

-(NSString*)objCStyleDescription {
    NSMutableString *output = [NSMutableString new];
    
    switch (self.cursor.kind) {
        case CXCursor_ObjCInstanceMethodDecl:
        case CXCursor_ObjCClassMethodDecl:
            [output appendString:[self debugDescriptionMethodDecl]];
            if (self.briefCommentText.length) {
                [output appendString:@"\n"];
                [output appendString:self.briefCommentText];
            }
            if (self.rawCommentText.length) {
                [output appendString:@"\n"];
                [output appendString:self.rawCommentText];
            }
            [output appendString:self.parsedComment.description];
            break;
            
        default:
            [output appendString:[self debugDescriptionUnkown]];
            break;
    }
    return output;
}

-(NSString*)debugDescriptionMethodDecl{
    NSMutableString *output = [NSMutableString new];
    NSMutableString *briefCommentOutput = [NSMutableString new];
    NSMutableString *rawCommentOutput = [NSMutableString new];
    __block NSUInteger paramaterCount = 0;
    
    [self enumerateMethodDecl:^(BOOL isClassMethod, BOOL isIntanceMethod, NSString *name, NSString *briefComment, NSString *rawComment, NSUInteger numParamaters) {
        if (isClassMethod) {
            [output appendString:@"+"];
        } else if (isIntanceMethod) {
            [output appendString:@"-"];
        }
        
        if (briefComment.length) {
            [briefCommentOutput appendString:name];
            [briefCommentOutput appendString:@" - "];
            [briefCommentOutput appendString:briefComment];
        }
        
        if (rawComment.length) {
            [rawCommentOutput appendString:name];
            [rawCommentOutput appendString:@" - "];
            [rawCommentOutput appendString:rawComment];
        }
            
    } result:^(BOOL isVoid, NSString *returnName) {
        [output appendFormat:@"(%@)", returnName];
    } name:^(NSString *name, NSString *briefComment, NSString *rawComment) {
        if (briefComment.length || rawCommentText.length) {
            NSLog(@"here");
        }
        
        if (paramaterCount) {
            [output appendString:@" "];
        }
        [output appendString:name];
    } paramater:^(NSString *paramaterName, NSString *paramaterType, NSString *briefComment, NSString *rawComment) {
        if (briefComment.length || rawCommentText.length) {
            NSLog(@"no here");
        }
        [output appendString:@":"];
        [output appendFormat:@"(%@)", paramaterType];
        [output appendString:paramaterName];
        paramaterCount++;
    }];
    return output;
}

-(NSString*)methodDeclBreifComment{
    NSMutableString *briefCommentOutput = [NSMutableString new];
    //__block NSUInteger paramaterCount = 0;
    
    [self enumerateMethodDecl:^(BOOL isClassMethod, BOOL isIntanceMethod, NSString *name, NSString *briefComment, NSString *rawComment, NSUInteger numParamaters) {
        
        if (briefComment.length) {
            //[briefCommentOutput appendString:name];
            //[briefCommentOutput appendString:@" - "];
            [briefCommentOutput appendString:briefComment];
            //if (isClassMethod) {
            //    [briefCommentOutput appendString:@" - Class Method"];
            //} else if (isIntanceMethod) {
            //    [briefCommentOutput appendString:@" - Instance Method"];
            //}
            //[briefCommentOutput appendString:@"\n"];
        }
        
        
    } result:^(BOOL isVoid, NSString *returnName) {
    } name:^(NSString *name, NSString *briefComment, NSString *rawComment) {
        if (briefComment.length) {
            //[briefCommentOutput appendString:name];
            //[briefCommentOutput appendString:@":"];
        }
    } paramater:^(NSString *paramaterName, NSString *paramaterType, NSString *briefComment, NSString *rawComment) {
        if (briefComment.length) {
            [briefCommentOutput appendString:paramaterName];
            [briefCommentOutput appendString:@" - "];
            [briefCommentOutput appendString:paramaterType];
            [briefCommentOutput appendString:@" - "];
            [briefCommentOutput appendString:briefComment];
            [briefCommentOutput appendString:@"\n"];
        }
    }];
    return briefCommentOutput;
}
-(NSString*)methodDeclRawComment{
    NSMutableString *rawCommentOutput = [NSMutableString new];
    //__block NSUInteger paramaterCount = 0;
    
    [self enumerateMethodDecl:^(BOOL isClassMethod, BOOL isIntanceMethod, NSString *name, NSString *briefComment, NSString *rawComment, NSUInteger numParamaters) {
        
        if (rawComment.length) {
            //[rawCommentOutput appendString:name];
            //[rawCommentOutput appendString:@" - "];
            [rawCommentOutput appendString:rawComment];
            //if (isClassMethod) {
            //    [rawCommentOutput appendString:@" - Class Method"];
            //} else if (isIntanceMethod) {
            //    [rawCommentOutput appendString:@" - Instance Method"];
            //}
            //[rawCommentOutput appendString:@"\n"];
        }
        
        
    } result:^(BOOL isVoid, NSString *returnName) {
    } name:^(NSString *name, NSString *briefComment, NSString *rawComment) {
        if (rawComment.length) {
            //[rawCommentOutput appendString:name];
            //[rawCommentOutput appendString:@":"];
        }
    } paramater:^(NSString *paramaterName, NSString *paramaterType, NSString *briefComment, NSString *rawComment) {
        if (rawComment.length) {
            [rawCommentOutput appendString:paramaterName];
            [rawCommentOutput appendString:@" - "];
            [rawCommentOutput appendString:paramaterType];
            [rawCommentOutput appendString:@" - "];
            [rawCommentOutput appendString:rawComment];
            [rawCommentOutput appendString:@"\n"];
        }
    }];
    return rawCommentOutput;
}

-(NSString*)debugDescriptionMethodDeclOld{
    //NSString *lnk = @"\n";
    NSMutableString *output = [NSMutableString new];
    
    // if return, display return
    if (self.cursorResultType.type.kind) {
        // has a return type
        [output appendFormat:@"(%@)",self.cursorResultType.typeSpelling];
    } else {
        [output appendString:@"(void)"];
    }
    
    if (self.numArguments == 0) {
        // no paramaters
        // display method name
        [output appendString:self.cursorDisplayName];
    } else {
        NSArray *methodNameByArguments = [self.cursorDisplayName componentsSeparatedByString:@":"];
        // loop paramaters
        for (NSInteger i=0; i<self.numArguments; i++) {
            CXCursorObjC *thisArgument = [self getArgument:i];
            [output appendFormat:@"%@:(%@)%@",[methodNameByArguments objectAtIndex:i], thisArgument.cursorType, thisArgument];
            if (i != (self.numArguments-1)) {
                [output appendString:@" "];
            }
        }
    }

    [output appendString:@";"];
    return output;
}


-(NSString*)debugDescriptionUnkown{
    
    //NSString *lnk = @"; ";
    NSString *lnk = @"\n";
    NSMutableString *output = [NSMutableString new];

    
    [output appendFormat:@"cursorSpelling = %@", self.cursorSpelling];

    [output appendString:lnk];
    [output appendFormat:@"cursorDisplayName = %@", self.cursorDisplayName];
    //CINDEX_LINKAGE CXString clang_getCursorDisplayName(CXCursor);

    [output appendString:lnk];
    [output appendFormat:@"cursorType = %@", self.cursorType];
    //CINDEX_LINKAGE CXType clang_getCursorType(CXCursor C);

    [output appendString:lnk];
    [output appendFormat:@"cursorResultType = %@", self.cursorResultType];
    //@property (nonatomic, readonly, strong) NSString *cursorResultType;
    //CINDEX_LINKAGE CXType clang_getCursorResultType(CXCursor C);
    
    [output appendString:lnk];
    [output appendFormat:@"numArguments = %ld", (long)self.numArguments];
    //@property (nonatomic, readonly) NSInteger numArguments;
    //CINDEX_LINKAGE int clang_Cursor_getNumArguments(CXCursor C);
    
    if (self.numArguments) {
        [output appendString:lnk];
        [output appendFormat:@"getArgument = %@", [self getArgument:0]];
    }
    //CINDEX_LINKAGE CXCursor clang_Cursor_getArgument(CXCursor C, unsigned i);
    
    __block NSMutableString *childStr = nil;
    if (self.numArguments) {
        
        [output appendString:lnk];
        BOOL res = [self visitChildrenWithBlock:^enum CXChildVisitResult(CXCursorObjC *cursor, CXCursorObjC *parent) {
            if (!childStr) {
                childStr = [NSMutableString stringWithFormat:@"Child debugDescriptions:"];
                [childStr appendString:lnk];
            }
            [childStr appendString:[cursor debugDescription]];
            [childStr appendString:lnk];
            return CXChildVisit_Continue;
        }];
        [output appendFormat:@"visitChildrenWithBlock = %hhd", res];
        //unsigned clang_visitChildrenWithBlock(CXCursor parent,
        //                                      CXCursorVisitorBlock block);
    }

    
    [output appendString:lnk];
    [output appendFormat:@"declObjCTypeEncoding = %@", self.declObjCTypeEncoding];
    //@property (nonatomic, readonly, strong) NSString *declObjCTypeEncoding;
    //CINDEX_LINKAGE CXString clang_getDeclObjCTypeEncoding(CXCursor C);

    
    [output appendString:lnk];
    [output appendFormat:@"rawCommentText = %@", self.rawCommentText];
    //CINDEX_LINKAGE CXString clang_Cursor_getRawCommentText(CXCursor C);
    
    [output appendString:lnk];
    [output appendFormat:@"briefCommentText = %@", self.briefCommentText];
    //CINDEX_LINKAGE CXString clang_Cursor_getBriefCommentText(CXCursor C);
    

    
    //[output appendFormat:@"nullCursor = %@", [CXCursorObjC nullCursor]];

    //CINDEX_LINKAGE CXCursor clang_getNullCursor(void);

    //CINDEX_LINKAGE CXCursor clang_getTranslationUnitCursor(CXTranslationUnit);

    //[output appendString:lnk];
    //[output appendFormat:@"equalCursors self = %hhd", [self equalCursors:self]];
    //[output appendString:lnk];
    //[output appendFormat:@"equalCursors nullCursor = %hhd", [self equalCursors:[CXCursorObjC nullCursor]]];
    //CINDEX_LINKAGE unsigned clang_equalCursors(CXCursor, CXCursor);

    [output appendString:lnk];
    [output appendFormat:@"isNull = %hhd", self.isNull];
    //@property (nonatomic, readonly) BOOL isNull;
    

    //[output appendString:lnk];
//@property (nonatomic, readonly) unsigned long *hashCursor;
//CINDEX_LINKAGE unsigned clang_hashCursor(CXCursor);

    
    [output appendString:lnk];
    [output appendFormat:@"cursorKind = %u", self.cursorKind];
//CINDEX_LINKAGE enum CXCursorKind clang_getCursorKind(CXCursor);

//CINDEX_LINKAGE enum CXLinkageKind clang_getCursorLinkage(CXCursor cursor);

    [output appendString:lnk];
    [output appendFormat:@"cursorAvailability = %u", self.cursorAvailability];
//CINDEX_LINKAGE enum CXAvailabilityKind clang_getCursorAvailability(CXCursor cursor);


    
//CINDEX_LINKAGE int
//clang_getCursorPlatformAvailability(CXCursor cursor,
//                                    int *always_deprecated,
//                                   CXString *deprecated_message,
//                                   int *always_unavailable,
//                                  CXString *unavailable_message,
//                                 CXPlatformAvailability *availability,
//                                int availability_size);


    [output appendString:lnk];
    [output appendFormat:@"cursorSemanticParent = %@", self.cursorSemanticParent];
//@property (nonatomic, strong, readonly) CXCursorObjC *cursorSemanticParent;
//CINDEX_LINKAGE CXCursor clang_getCursorSemanticParent(CXCursor cursor);

    [output appendString:lnk];
    [output appendFormat:@"cursorLexicalParent = %@", self.cursorLexicalParent];
//@property (nonatomic, strong, readonly) CXCursorObjC *cursorLexicalParent;
//CINDEX_LINKAGE CXCursor clang_getCursorLexicalParent(CXCursor cursor);

//CINDEX_LINKAGE void clang_getOverriddenCursors(CXCursor cursor,
//                                               CXCursor **overridden,
//                                               unsigned *num_overridden);

//CINDEX_LINKAGE void clang_disposeOverriddenCursors(CXCursor *overridden);

    [output appendString:lnk];
    [output appendFormat:@"includedFile = %@", self.includedFile];
//@property (nonatomic, strong, readonly) CXFileObjC *includedFile;
//CINDEX_LINKAGE CXFile clang_getIncludedFile(CXCursor cursor);

    


    [output appendString:lnk];
    [output appendFormat:@"typedefDeclUnderlyingType = %@", self.typedefDeclUnderlyingType];
//@property (nonatomic, strong, readonly) CXTypeObjC *typedefDeclUnderlyingType;
//CINDEX_LINKAGE CXType clang_getTypedefDeclUnderlyingType(CXCursor C);

    [output appendString:lnk];
    [output appendFormat:@"enumDeclIntegerType = %@", self.enumDeclIntegerType];
//@property (nonatomic, strong, readonly) CXTypeObjC *enumDeclIntegerType;
//CINDEX_LINKAGE CXType clang_getEnumDeclIntegerType(CXCursor C);

    [output appendString:lnk];
    [output appendFormat:@"enumConstantDeclValue = %lld", self.enumConstantDeclValue];
//@property (nonatomic, readonly) long long *enumConstantDeclValue;
//CINDEX_LINKAGE long long clang_getEnumConstantDeclValue(CXCursor C);

    [output appendString:lnk];
    [output appendFormat:@"enumConstantDeclUnsignedValue = %lld", self.enumConstantDeclUnsignedValue];
//@property (nonatomic, readonly) long long *enumConstantDeclUnsignedValue;
//CINDEX_LINKAGE unsigned long long clang_getEnumConstantDeclUnsignedValue(CXCursor C);

//CINDEX_LINKAGE int clang_getFieldDeclBitWidth(CXCursor C);




    [output appendString:lnk];
    [output appendFormat:@"isBitField = %hhd", self.isBitField];
//@property (nonatomic, readonly) BOOL isBitField;
//CINDEX_LINKAGE unsigned clang_Cursor_isBitField(CXCursor C);

    [output appendString:lnk];
    [output appendFormat:@"isVirtualBase = %hhd", self.isVirtualBase];
//@property (nonatomic, readonly) BOOL isVirtualBase;
//CINDEX_LINKAGE unsigned clang_isVirtualBase(CXCursor);

//enum CX_CXXAccessSpecifier {
//    CX_CXXInvalidAccessSpecifier,
//    CX_CXXPublic,
//    CX_CXXProtected,
//    CX_CXXPrivate
//};

//CINDEX_LINKAGE enum CX_CXXAccessSpecifier clang_getCXXAccessSpecifier(CXCursor);

//CINDEX_LINKAGE unsigned clang_getNumOverloadedDecls(CXCursor cursor);

//CINDEX_LINKAGE CXCursor clang_getOverloadedDecl(CXCursor cursor,
//                                                unsigned index);

//CINDEX_LINKAGE CXType clang_getIBOutletCollectionType(CXCursor);

//typedef enum CXChildVisitResult (*CXCursorVisitor)(CXCursor cursor,
//CXCursor parent,
//CXClientData client_data);

//CINDEX_LINKAGE unsigned clang_visitChildren(CXCursor parent,
//                                            CXCursorVisitor visitor,
//                                            CXClientData client_data);




    [output appendString:lnk];
    [output appendFormat:@"cursorUSR = %@", self.cursorUSR];
//@property (nonatomic, readonly) NSString *cursorUSR;
//CINDEX_LINKAGE CXString clang_getCursorUSR(CXCursor);

//CINDEX_LINKAGE CXSourceRange clang_Cursor_getSpellingNameRange(CXCursor,
//                                                               unsigned pieceIndex,
//                                                               unsigned options);



    [output appendString:lnk];
    [output appendFormat:@"cursorReferenced = %@", self.cursorReferenced];
//@property (nonatomic, readonly, strong) NSString *cursorReferenced;
//CINDEX_LINKAGE CXCursor clang_getCursorReferenced(CXCursor);

    [output appendString:lnk];
    [output appendFormat:@"cursorDefinition = %@", self.cursorDefinition];
//@property (nonatomic, readonly, strong) CXCursorObjC *cursorDefinition;
//CINDEX_LINKAGE CXCursor clang_getCursorDefinition(CXCursor);

    [output appendString:lnk];
    [output appendFormat:@"isCursorDefinition = %hhd", self.isCursorDefinition];
//@property (nonatomic, readonly) BOOL isCursorDefinition;
//CINDEX_LINKAGE unsigned clang_isCursorDefinition(CXCursor);

    [output appendString:lnk];
    [output appendFormat:@"canonicalCursor = %@", self.canonicalCursor];
//@property (nonatomic, readonly, strong) CXCursorObjC *canonicalCursor;
//CINDEX_LINKAGE CXCursor clang_getCanonicalCursor(CXCursor);

    [output appendString:lnk];
    [output appendFormat:@"objCSelectorIndex = %ld", (long)self.objCSelectorIndex];
//@property (nonatomic, readonly) NSInteger objCSelectorIndex;
//CINDEX_LINKAGE int clang_Cursor_getObjCSelectorIndex(CXCursor);

    [output appendString:lnk];
    [output appendFormat:@"isDynamicCall = %hhd", self.isDynamicCall];
//@property (nonatomic, readonly) BOOL isDynamicCall;
//CINDEX_LINKAGE int clang_Cursor_isDynamicCall(CXCursor C);

    [output appendString:lnk];
    [output appendFormat:@"receiverType = %@", self.receiverType];
//@property (nonatomic, readonly, strong) CXTypeObjC *receiverType;
//CINDEX_LINKAGE CXType clang_Cursor_getReceiverType(CXCursor C);

    [output appendString:lnk];
    [output appendFormat:@"objCPropertyAttributes = %lu", (unsigned long)self.objCPropertyAttributes];
//-(NSUInteger)objCPropertyAttributes;
//CINDEX_LINKAGE unsigned clang_Cursor_getObjCPropertyAttributes(CXCursor C,
//                                                               unsigned reserved);

    [output appendString:lnk];
    [output appendFormat:@"objCDeclQualifiers = %ld", (long)self.objCDeclQualifiers];
//@property (nonatomic, readonly) NSInteger objCDeclQualifiers;
//CINDEX_LINKAGE unsigned clang_Cursor_getObjCDeclQualifiers(CXCursor C);

    [output appendString:lnk];
    [output appendFormat:@"isObjCOptional = %hhd", self.isObjCOptional];
//@property (nonatomic, readonly) BOOL isObjCOptional;
//CINDEX_LINKAGE unsigned clang_Cursor_isObjCOptional(CXCursor C);

    [output appendString:lnk];
    [output appendFormat:@"isVariadic = %hhd", self.isVariadic];
//@property (nonatomic, readonly) BOOL isVariadic;
//CINDEX_LINKAGE unsigned clang_Cursor_isVariadic(CXCursor C);

//CINDEX_LINKAGE CXSourceRange clang_Cursor_getCommentRange(CXCursor C);

//CINDEX_LINKAGE CXComment clang_Cursor_getParsedComment(CXCursor C);
    

//CINDEX_LINKAGE CXModule clang_Cursor_getModule(CXCursor C);

    [output appendString:lnk];
    [output appendFormat:@"isPureVirtual = %hhd", self.isPureVirtual];
//@property (nonatomic, readonly) BOOL isPureVirtual;
//CINDEX_LINKAGE unsigned clang_CXXMethod_isPureVirtual(CXCursor C);

    [output appendString:lnk];
    [output appendFormat:@"isStatic = %hhd", self.isStatic];
//@property (nonatomic, readonly) BOOL isStatic;
//CINDEX_LINKAGE unsigned clang_CXXMethod_isStatic(CXCursor C);

    [output appendString:lnk];
    [output appendFormat:@"isVirtual = %hhd", self.isVirtual];
//@property (nonatomic, readonly) BOOL isVirtual;
//CINDEX_LINKAGE unsigned clang_CXXMethod_isVirtual(CXCursor C);

//CINDEX_LINKAGE enum CXCursorKind clang_getTemplateCursorKind(CXCursor C);

    [output appendString:lnk];
    [output appendFormat:@"specializedCursorTemplate = %@", self.specializedCursorTemplate];
//@property (nonatomic, readonly, strong) CXCursorObjC *specializedCursorTemplate;
//CINDEX_LINKAGE CXCursor clang_getSpecializedCursorTemplate(CXCursor C);
    
    if (childStr) {
        [output appendString:@"\n"];
        [output appendString:childStr];
    }
    
    return (output);
}

@end
