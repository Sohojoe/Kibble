//
//  CXCommentObjC.m
//  ObjectiveBrowser
//
//  Created by Joe on 3/8/14.
//
//

#import "CXCommentObjC.h"
#import "CXCommentObjC+Private.h"
#import <clang-c/Index.h>

@interface CXCommentObjC()
@property (nonatomic) CXComment comment;
@end


@implementation CXCommentObjC

-(NSString*)description{
    return [self commentDescription];
}
-(NSString*)debugDescription{
    return [self debugDescriptionFull];
}


-(void)enumerateNodes:(void (^)(CXCommentObjC *commentNode)) nodeBlock{
    
    if (nodeBlock) {
        nodeBlock(self);

        
        NSUInteger numChild = clang_Comment_getNumChildren(self.comment);

        for (int i=0; i<numChild; i++) {
            CXCommentObjC* child = [CXCommentObjC commentFrom:clang_Comment_getChild(self.comment, i)];
            [child enumerateNodes:nodeBlock];
        }
    }
    
    
}

-(void)enumerateComments:(void (^)(BOOL isBreif,
                                   BOOL isReturn,
                                   BOOL isParameter,
                                   NSString* comment,
                                   NSString* commandName,
                                   NSString* paramName,
                                   NSString* argumentName,
                                   NSUInteger parameterIndex
                                   )) block{
    __block BOOL isBreif;
    __block BOOL isReturn;
    __block BOOL isParameter;
    __block NSString* comment;
    __block NSString* commandName;
    __block NSString* paramName;
    __block NSString* argumentName;
    __block NSUInteger parameterIndex;

    parameterIndex = 0;

    [self enumerateNodes:^(CXCommentObjC *childWithBlock) {
        if (clang_Comment_getKind(childWithBlock.comment) == CXComment_ParamCommand ||
            clang_Comment_getKind(childWithBlock.comment) == CXComment_BlockCommand) {

            // reset values
            isBreif = NO;
            isReturn = NO;
            isParameter = NO;
            comment = nil;
            commandName = nil;
            paramName = nil;
            argumentName = nil;
            
            const char *cStr;
            cStr = clang_getCString(clang_BlockCommandComment_getCommandName(childWithBlock.comment));
            commandName = [NSString stringWithUTF8String:cStr];
            
            if (clang_Comment_getKind(childWithBlock.comment) == CXComment_ParamCommand) {
                cStr = clang_getCString(clang_BlockCommandComment_getArgText(childWithBlock.comment,0));
                argumentName = [NSString stringWithUTF8String:cStr];
                cStr = clang_getCString(clang_ParamCommandComment_getParamName(childWithBlock.comment));
                paramName = [NSString stringWithUTF8String:cStr];
                isParameter = YES;
            }
            [childWithBlock enumerateNodes:^(CXCommentObjC *childWithComment) {
                if (clang_Comment_getKind(childWithComment.comment) == CXComment_Text ) {
                    const char *cStr;
                    cStr = clang_getCString(clang_TextComment_getText(childWithComment.comment));
                    if (!cStr) cStr = [@"" UTF8String];
                    comment = [NSString stringWithUTF8String:cStr];
                }
            }];
            //NSLog(@"%@ = %@", thisField, thisComment);
            if (isParameter == NO) {
                if ([@"brief" caseInsensitiveCompare:commandName] == NSOrderedSame) {
                    isBreif = YES;
                } else if ([@"returns" caseInsensitiveCompare:commandName] == NSOrderedSame) {
                    isReturn = YES;
                }
            }
            // call the block
            if (block) {
                block (isBreif, isReturn, isParameter,
                       comment,
                       commandName,
                       paramName, argumentName, parameterIndex);
            }
            if (isParameter) {
                parameterIndex++;
            }
        }
        
    }];
    
    
}
-(NSString*)commentDescription{
    __block NSMutableString *output = [NSMutableString new];
    
    [self enumerateComments:^(BOOL isBreif, BOOL isReturn, BOOL isParameter, NSString *comment, NSString *commandName, NSString *paramName, NSString *argumentName, NSUInteger parameterIndex) {
        
        if (isBreif) {
            [output appendFormat:@"%@ - %@\n", commandName, comment];
        } else if (isReturn) {
            [output appendFormat:@"%@ - %@\n", commandName, comment];
        } else if (isParameter) {
            //[output appendFormat:@"%@(%lu-%@)\n %@ - %@\n", commandName, (unsigned long)parameterIndex, argumentName, paramName, comment];
            [output appendFormat:@"%@(%lu) %@ - %@\n", commandName, (unsigned long)parameterIndex, paramName, comment];
        }
        
    }];
    return output;
}

-(NSString*)commentFor:(NSUInteger)paramater{
    
    return self.description;
    
    CXCommentObjC* child = [CXCommentObjC commentFrom:clang_Comment_getChild(self.comment, (unsigned)paramater)];
    NSString *str = nil;
    const char *cstr;
    
    __block NSString *thisField = nil;
    __block NSString *thisComment = nil;
    
    
    [self enumerateNodes:^(CXCommentObjC *childWithBlock) {
        if (clang_Comment_getKind(childWithBlock.comment) == CXComment_ParamCommand ||
            clang_Comment_getKind(childWithBlock.comment) == CXComment_BlockCommand) {
            //CXComment_BlockCommand ) {
            const char *thisFieldRaw;
            thisFieldRaw = clang_getCString(clang_BlockCommandComment_getCommandName(childWithBlock.comment));
            thisField = [NSString stringWithUTF8String:thisFieldRaw];
            if (clang_Comment_getKind(childWithBlock.comment) == CXComment_ParamCommand) {
                thisFieldRaw = clang_getCString(clang_ParamCommandComment_getParamName(childWithBlock.comment));
                thisField = [NSString stringWithFormat:@"%@ (%s)", thisField, thisFieldRaw];
            }
            [childWithBlock enumerateNodes:^(CXCommentObjC *childWithComment) {
                if (clang_Comment_getKind(childWithComment.comment) == CXComment_Text ) {
                    const char *thisCommentRaw;
                    thisCommentRaw = clang_getCString(clang_TextComment_getText(childWithComment.comment));
                    if (!thisCommentRaw) thisCommentRaw = [@"" UTF8String];
                    thisComment = [NSString stringWithUTF8String:thisCommentRaw];
                }
            }];
            NSLog(@"%@ = %@", thisField, thisComment);
        }

    }];
            
    
    if (clang_Comment_getKind(child.comment) == CXComment_Paragraph) {
        
    }
    
    cstr = clang_getCString(clang_VerbatimBlockLineComment_getText(child.comment));
    if (cstr) {
        str = [NSString stringWithFormat:@"%s", cstr];
    }
    
    
    cstr = clang_getCString(clang_InlineCommandComment_getArgText(self.comment, (unsigned)paramater));
    if (cstr) {
        str = [NSString stringWithFormat:@"%s", cstr];
    }

    cstr = clang_getCString(clang_HTMLStartTag_getAttrName(self.comment, (unsigned)paramater));
    if (cstr) {
        str = [NSString stringWithFormat:@"%s", cstr];
    }

    cstr = clang_getCString(clang_HTMLStartTag_getAttrValue(self.comment, (unsigned)paramater));
    if (cstr) {
        str = [NSString stringWithFormat:@"%s", cstr];
    }

    cstr = clang_getCString(clang_BlockCommandComment_getArgText(self.comment, (unsigned)paramater));
    if (cstr) {
        str = [NSString stringWithFormat:@"%s", cstr];
    }
    return str;

}


-(NSString*)debugDescriptionFull{
    
    if (clang_Comment_getKind(self.comment) == CXComment_Null) {
        return @"";
    }
    
    
    NSString *lnk = @"\n";
    NSMutableString *output = [NSMutableString new];
    NSMutableString *childOutput = [NSMutableString new];

    const char *cstr;
    /**
     * \param Comment AST node of any kind.
     *
     * \returns the type of the AST node.
     */
    //CINDEX_LINKAGE enum CXCommentKind clang_Comment_getKind(CXComment Comment);
    [output appendString:lnk];
    [output appendFormat:@"clang_Comment_getKind = %u", clang_Comment_getKind(self.comment)];
    
    /**
     * \param Comment AST node of any kind.
     *
     * \returns number of children of the AST node.
     */
    //CINDEX_LINKAGE unsigned clang_Comment_getNumChildren(CXComment Comment);
    [output appendString:lnk];
    NSUInteger numChild = clang_Comment_getNumChildren(self.comment);
    [output appendFormat:@"clang_Comment_getNumChildren = %lu", (unsigned long)numChild];
    
    /**
     * \param Comment AST node of any kind.
     *
     * \param ChildIdx child index (zero-based).
     *
     * \returns the specified child of the AST node.
     */
    //CINDEX_LINKAGE
    //CXComment clang_Comment_getChild(CXComment Comment, unsigned ChildIdx);
    for (int i=0; i<numChild; i++) {
        [output appendString:lnk];
        CXCommentObjC* child = [CXCommentObjC commentFrom:clang_Comment_getChild(self.comment, i)];
        
        [childOutput appendString:child.description];
        [childOutput appendString:lnk];
    }

    
    /**
     * \brief A \c CXComment_Paragraph node is considered whitespace if it contains
     * only \c CXComment_Text nodes that are empty or whitespace.
     *
     * Other AST nodes (except \c CXComment_Paragraph and \c CXComment_Text) are
     * never considered whitespace.
     *
     * \returns non-zero if \c Comment is whitespace.
     */
    //CINDEX_LINKAGE unsigned clang_Comment_isWhitespace(CXComment Comment);
    [output appendString:lnk];
    [output appendFormat:@"clang_Comment_isWhitespace = %u", clang_Comment_isWhitespace(self.comment)];
    
    /**
     * \returns non-zero if \c Comment is inline content and has a newline
     * immediately following it in the comment text.  Newlines between paragraphs
     * do not count.
     */
    //CINDEX_LINKAGE unsigned clang_InlineContentComment_hasTrailingNewline(CXComment Comment);
    [output appendString:lnk];
    [output appendFormat:@"clang_InlineContentComment_hasTrailingNewline = %u", clang_InlineContentComment_hasTrailingNewline(self.comment)];
    
    /**
     * \param Comment a \c CXComment_Text AST node.
     *
     * \returns text contained in the AST node.
     */
    //CINDEX_LINKAGE CXString clang_TextComment_getText(CXComment Comment);
    [output appendString:lnk];
    cstr = clang_getCString(clang_TextComment_getText(self.comment));
    if (!cstr) cstr = [@"" UTF8String];
    [output appendFormat:@"clang_TextComment_getText = %@", [NSString stringWithUTF8String:cstr]];
     
     
    /**
     * \param Comment a \c CXComment_InlineCommand AST node.
     *
     * \returns name of the inline command.
     */
    //CINDEX_LINKAGE    CXString clang_InlineCommandComment_getCommandName(CXComment Comment);
    [output appendString:lnk];
    cstr = clang_getCString(clang_InlineCommandComment_getCommandName(self.comment));
    if (!cstr) cstr = [@"" UTF8String];
    [output appendFormat:@"clang_InlineCommandComment_getCommandName = %@", [NSString stringWithUTF8String:cstr]];
    
    /**
     * \param Comment a \c CXComment_InlineCommand AST node.
     *
     * \returns the most appropriate rendering mode, chosen on command
     * semantics in Doxygen.
     */
    //CINDEX_LINKAGE enum CXCommentInlineCommandRenderKind clang_InlineCommandComment_getRenderKind(CXComment Comment);
    [output appendString:lnk];
    [output appendFormat:@"clang_InlineCommandComment_getRenderKind = %u", clang_InlineCommandComment_getRenderKind(self.comment)];
    
    /**
     * \param Comment a \c CXComment_InlineCommand AST node.
     *
     * \returns number of command arguments.
     */
    //CINDEX_LINKAGE unsigned clang_InlineCommandComment_getNumArgs(CXComment Comment);
    [output appendString:lnk];
    [output appendFormat:@"clang_InlineCommandComment_getNumArgs = %u", clang_InlineCommandComment_getNumArgs(self.comment)];
    
    /**
     * \param Comment a \c CXComment_InlineCommand AST node.
     *
     * \param ArgIdx argument index (zero-based).
     *
     * \returns text of the specified argument.
     */
    //CINDEX_LINKAGE CXString clang_InlineCommandComment_getArgText(CXComment Comment, unsigned ArgIdx);
    for (int i=0; i<numChild; i++) {
        cstr = clang_getCString(clang_InlineCommandComment_getArgText(self.comment, i));
        if (!cstr) cstr = [@"" UTF8String];
        [output appendFormat:@"clang_InlineCommandComment_getArgText = %@", [NSString stringWithUTF8String:cstr]];
    }
    
    /**
     * \param Comment a \c CXComment_HTMLStartTag or \c CXComment_HTMLEndTag AST
     * node.
     *
     * \returns HTML tag name.
     */
    //CINDEX_LINKAGE CXString clang_HTMLTagComment_getTagName(CXComment Comment);
    [output appendString:lnk];
    cstr = clang_getCString(clang_HTMLTagComment_getTagName(self.comment));
    if (!cstr) cstr = [@"" UTF8String];
    [output appendFormat:@"clang_HTMLTagComment_getTagName = %@", [NSString stringWithUTF8String:cstr]];
    
    /**
     * \param Comment a \c CXComment_HTMLStartTag AST node.
     *
     * \returns non-zero if tag is self-closing (for example, &lt;br /&gt;).
     */
    //CINDEX_LINKAGE unsigned clang_HTMLStartTagComment_isSelfClosing(CXComment Comment);
    [output appendString:lnk];
    [output appendFormat:@"clang_HTMLStartTagComment_isSelfClosing = %u", clang_HTMLStartTagComment_isSelfClosing(self.comment)];
    
    /**
     * \param Comment a \c CXComment_HTMLStartTag AST node.
     *
     * \returns number of attributes (name-value pairs) attached to the start tag.
     */
    //CINDEX_LINKAGE unsigned clang_HTMLStartTag_getNumAttrs(CXComment Comment);
    [output appendString:lnk];
    [output appendFormat:@"clang_HTMLStartTag_getNumAttrs = %u", clang_HTMLStartTag_getNumAttrs(self.comment)];
    
    /**
     * \param Comment a \c CXComment_HTMLStartTag AST node.
     *
     * \param AttrIdx attribute index (zero-based).
     *
     * \returns name of the specified attribute.
     */
    //CINDEX_LINKAGE  CXString clang_HTMLStartTag_getAttrName(CXComment Comment, unsigned AttrIdx);
    for (int i=0; i<numChild; i++) {
        [output appendString:lnk];
        cstr = clang_getCString(clang_HTMLStartTag_getAttrName(self.comment, i));
        if (!cstr) cstr = [@"" UTF8String];
        [output appendFormat:@"clang_HTMLStartTag_getAttrName = %@", [NSString stringWithUTF8String:cstr]];
    }
    
    /**
     * \param Comment a \c CXComment_HTMLStartTag AST node.
     *
     * \param AttrIdx attribute index (zero-based).
     *
     * \returns value of the specified attribute.
     */
    //CINDEX_LINKAGE CXString clang_HTMLStartTag_getAttrValue(CXComment Comment, unsigned AttrIdx);
    for (int i=0; i<numChild; i++) {
        [output appendString:lnk];
        cstr = clang_getCString(clang_HTMLStartTag_getAttrValue(self.comment, i));
        if (!cstr) cstr = [@"" UTF8String];
        [output appendFormat:@"clang_HTMLStartTag_getAttrValue = %@", [NSString stringWithUTF8String:cstr]];
    }
    
    /**
     * \param Comment a \c CXComment_BlockCommand AST node.
     *
     * \returns name of the block command.
     */
    //CINDEX_LINKAGE CXString clang_BlockCommandComment_getCommandName(CXComment Comment);
    [output appendString:lnk];
    cstr = clang_getCString(clang_BlockCommandComment_getCommandName(self.comment));
    if (!cstr) cstr = [@"" UTF8String];
    [output appendFormat:@"clang_BlockCommandComment_getCommandName = %@", [NSString stringWithUTF8String:cstr]];
    
    /**
     * \param Comment a \c CXComment_BlockCommand AST node.
     *
     * \returns number of word-like arguments.
     */
    //CINDEX_LINKAGE unsigned clang_BlockCommandComment_getNumArgs(CXComment Comment);
    [output appendString:lnk];
    [output appendFormat:@"clang_BlockCommandComment_getNumArgs = %u", clang_BlockCommandComment_getNumArgs(self.comment)];
    
    /**
     * \param Comment a \c CXComment_BlockCommand AST node.
     *
     * \param ArgIdx argument index (zero-based).
     *
     * \returns text of the specified word-like argument.
     */
    //CINDEX_LINKAGE CXString clang_BlockCommandComment_getArgText(CXComment Comment,
    //                                              unsigned ArgIdx);
    for (int i=0; i<numChild; i++) {
        [output appendString:lnk];
        cstr = clang_getCString(clang_BlockCommandComment_getArgText(self.comment, i));
        if (!cstr) cstr = [@"" UTF8String];
        [output appendFormat:@"clang_BlockCommandComment_getArgText = %@", [NSString stringWithUTF8String:cstr]];
    }
    
    /**
     * \param Comment a \c CXComment_BlockCommand or
     * \c CXComment_VerbatimBlockCommand AST node.
     *
     * \returns paragraph argument of the block command.
     */
    //CINDEX_LINKAGE
    //CXComment clang_BlockCommandComment_getParagraph(CXComment Comment);
    [output appendString:lnk];
    CXCommentObjC *c = [CXCommentObjC commentFrom:clang_BlockCommandComment_getParagraph(self.comment)];
//    [output appendFormat:@"clang_BlockCommandComment_getParagraph = %@", c.description];
    
    /**
     * \param Comment a \c CXComment_ParamCommand AST node.
     *
     * \returns parameter name.
     */
    //CINDEX_LINKAGE
    //CXString clang_ParamCommandComment_getParamName(CXComment Comment);
    [output appendString:lnk];
    cstr = clang_getCString(clang_ParamCommandComment_getParamName(self.comment));
    if (!cstr) cstr = [@"" UTF8String];
    [output appendFormat:@"clang_ParamCommandComment_getParamName = %@", [NSString stringWithUTF8String:cstr]];
    
    /**
     * \param Comment a \c CXComment_ParamCommand AST node.
     *
     * \returns non-zero if the parameter that this AST node represents was found
     * in the function prototype and \c clang_ParamCommandComment_getParamIndex
     * function will return a meaningful value.
     */
    //CINDEX_LINKAGE
    //unsigned clang_ParamCommandComment_isParamIndexValid(CXComment Comment);
    [output appendString:lnk];
    [output appendFormat:@"clang_ParamCommandComment_isParamIndexValid = %u", clang_ParamCommandComment_isParamIndexValid(self.comment)];
    
    /**
     * \param Comment a \c CXComment_ParamCommand AST node.
     *
     * \returns zero-based parameter index in function prototype.
     */
    //CINDEX_LINKAGE
    //unsigned clang_ParamCommandComment_getParamIndex(CXComment Comment);
    [output appendString:lnk];
    [output appendFormat:@"clang_ParamCommandComment_getParamIndex = %u", clang_ParamCommandComment_getParamIndex(self.comment)];
    
    /**
     * \param Comment a \c CXComment_ParamCommand AST node.
     *
     * \returns non-zero if parameter passing direction was specified explicitly in
     * the comment.
     */
    //CINDEX_LINKAGE
    //unsigned clang_ParamCommandComment_isDirectionExplicit(CXComment Comment);
    [output appendString:lnk];
    [output appendFormat:@"clang_ParamCommandComment_isDirectionExplicit = %u", clang_ParamCommandComment_isDirectionExplicit(self.comment)];
    
    /**
     * \param Comment a \c CXComment_ParamCommand AST node.
     *
     * \returns parameter passing direction.
     */
    //CINDEX_LINKAGE
    //enum CXCommentParamPassDirection clang_ParamCommandComment_getDirection(
    //                                                                        CXComment Comment);
    [output appendString:lnk];
    [output appendFormat:@"clang_ParamCommandComment_getDirection = %u", clang_ParamCommandComment_getDirection(self.comment)];
    
    /**
     * \param Comment a \c CXComment_TParamCommand AST node.
     *
     * \returns template parameter name.
     */
    //CINDEX_LINKAGE
    //CXString clang_TParamCommandComment_getParamName(CXComment Comment);
    [output appendString:lnk];
    cstr = clang_getCString(clang_TParamCommandComment_getParamName(self.comment));
    if (!cstr) cstr = [@"" UTF8String];
    [output appendFormat:@"clang_TParamCommandComment_getParamName = %@", [NSString stringWithUTF8String:cstr]];
    
    /**
     * \param Comment a \c CXComment_TParamCommand AST node.
     *
     * \returns non-zero if the parameter that this AST node represents was found
     * in the template parameter list and
     * \c clang_TParamCommandComment_getDepth and
     * \c clang_TParamCommandComment_getIndex functions will return a meaningful
     * value.
     */
    //CINDEX_LINKAGE
    //unsigned clang_TParamCommandComment_isParamPositionValid(CXComment Comment);
    [output appendString:lnk];
    [output appendFormat:@"clang_TParamCommandComment_isParamPositionValid = %u", clang_TParamCommandComment_isParamPositionValid(self.comment)];
    
    /**
     * \param Comment a \c CXComment_TParamCommand AST node.
     *
     * \returns zero-based nesting depth of this parameter in the template parameter list.
     *
     * For example,
     * \verbatim
     *     template<typename C, template<typename T> class TT>
     *     void test(TT<int> aaa);
     * \endverbatim
     * for C and TT nesting depth is 0,
     * for T nesting depth is 1.
     */
    //CINDEX_LINKAGE
    //unsigned clang_TParamCommandComment_getDepth(CXComment Comment);
    [output appendString:lnk];
    [output appendFormat:@"clang_TParamCommandComment_getDepth = %u", clang_TParamCommandComment_getDepth(self.comment)];
    
    /**
     * \param Comment a \c CXComment_TParamCommand AST node.
     *
     * \returns zero-based parameter index in the template parameter list at a
     * given nesting depth.
     *
     * For example,
     * \verbatim
     *     template<typename C, template<typename T> class TT>
     *     void test(TT<int> aaa);
     * \endverbatim
     * for C and TT nesting depth is 0, so we can ask for index at depth 0:
     * at depth 0 C's index is 0, TT's index is 1.
     *
     * For T nesting depth is 1, so we can ask for index at depth 0 and 1:
     * at depth 0 T's index is 1 (same as TT's),
     * at depth 1 T's index is 0.
     */
    //CINDEX_LINKAGE
    //unsigned clang_TParamCommandComment_getIndex(CXComment Comment, unsigned Depth);
    [output appendString:lnk];
    [output appendFormat:@"clang_TParamCommandComment_getIndex = %u", clang_TParamCommandComment_getIndex(self.comment, 0)];
    
    /**
     * \param Comment a \c CXComment_VerbatimBlockLine AST node.
     *
     * \returns text contained in the AST node.
     */
    //CINDEX_LINKAGE
    //CXString clang_VerbatimBlockLineComment_getText(CXComment Comment);
    [output appendString:lnk];
    cstr = clang_getCString(clang_VerbatimBlockLineComment_getText(self.comment));
    if (!cstr) cstr = [@"" UTF8String];
    [output appendFormat:@"clang_VerbatimBlockLineComment_getText = %@", [NSString stringWithUTF8String:cstr]];
    
    /**
     * \param Comment a \c CXComment_VerbatimLine AST node.
     *
     * \returns text contained in the AST node.
     */
    //CINDEX_LINKAGE CXString clang_VerbatimLineComment_getText(CXComment Comment);
    [output appendString:lnk];
    cstr = clang_getCString(clang_VerbatimLineComment_getText(self.comment));
    if (!cstr) cstr = [@"" UTF8String];
    [output appendFormat:@"clang_VerbatimLineComment_getText = %@", [NSString stringWithUTF8String:cstr]];
    
    /**
     * \brief Convert an HTML tag AST node to string.
     *
     * \param Comment a \c CXComment_HTMLStartTag or \c CXComment_HTMLEndTag AST
     * node.
     *
     * \returns string containing an HTML tag.
     */
    //CINDEX_LINKAGE CXString clang_HTMLTagComment_getAsString(CXComment Comment);
    [output appendString:lnk];
    cstr = clang_getCString(clang_HTMLTagComment_getAsString(self.comment));
    if (!cstr) cstr = [@"" UTF8String];
    [output appendFormat:@"clang_HTMLTagComment_getAsString = %@", [NSString stringWithUTF8String:cstr]];
    
    /**
     * \brief Convert a given full parsed comment to an HTML fragment.
     *
     * Specific details of HTML layout are subject to change.  Don't try to parse
     * this HTML back into an AST, use other APIs instead.
     *
     * Currently the following CSS classes are used:
     * \li "para-brief" for \\brief paragraph and equivalent commands;
     * \li "para-returns" for \\returns paragraph and equivalent commands;
     * \li "word-returns" for the "Returns" word in \\returns paragraph.
     *
     * Function argument documentation is rendered as a \<dl\> list with arguments
     * sorted in function prototype order.  CSS classes used:
     * \li "param-name-index-NUMBER" for parameter name (\<dt\>);
     * \li "param-descr-index-NUMBER" for parameter description (\<dd\>);
     * \li "param-name-index-invalid" and "param-descr-index-invalid" are used if
     * parameter index is invalid.
     *
     * Template parameter documentation is rendered as a \<dl\> list with
     * parameters sorted in template parameter list order.  CSS classes used:
     * \li "tparam-name-index-NUMBER" for parameter name (\<dt\>);
     * \li "tparam-descr-index-NUMBER" for parameter description (\<dd\>);
     * \li "tparam-name-index-other" and "tparam-descr-index-other" are used for
     * names inside template template parameters;
     * \li "tparam-name-index-invalid" and "tparam-descr-index-invalid" are used if
     * parameter position is invalid.
     *
     * \param Comment a \c CXComment_FullComment AST node.
     *
     * \returns string containing an HTML fragment.
     */
    //CINDEX_LINKAGE CXString clang_FullComment_getAsHTML(CXComment Comment);
    [output appendString:lnk];
    cstr = clang_getCString(clang_FullComment_getAsHTML(self.comment));
    if (!cstr) cstr = [@"" UTF8String];
    [output appendFormat:@"clang_FullComment_getAsHTML = %@", [NSString stringWithUTF8String:cstr]];
    
    /**
     * \brief Convert a given full parsed comment to an XML document.
     *
     * A Relax NG schema for the XML can be found in comment-xml-schema.rng file
     * inside clang source tree.
     *
     * \param Comment a \c CXComment_FullComment AST node.
     *
     * \returns string containing an XML document.
     */
    //CINDEX_LINKAGE CXString clang_FullComment_getAsXML(CXComment Comment);
    [output appendString:lnk];
    cstr = clang_getCString(clang_FullComment_getAsXML(self.comment));
    if (!cstr) cstr = [@"" UTF8String];
    [output appendFormat:@"clang_FullComment_getAsXML = %@", [NSString stringWithUTF8String:cstr]];

    [output appendString:@"\n"];
    [output appendString:childOutput];
    
    return output;
}

@end
