//
//  CXCursorObjC.h
//  ObjectiveBrowser
//
//  Created by Joe on 3/6/14.
//
//

#import <Foundation/Foundation.h>
//#import <clang-c/Index.h>


//----------------------------------------------------------------

@class CXFileObjC;
@class CXTypeObjC;
@class CXCommentObjC;

@interface CXCursorObjC : NSObject
/**
 * \brief Creates ObjectiveC class wrapper around CXCursor
 *
 * \param cursor The cursor to wrap.
 *
 * \returns The ObjectiveC object.
 */
+(CXCursorObjC *)cursorFromPointer:(void *) ptrToThisCursor;


/**
 * \brief Retrieve the NULL cursor, which represents no entity.
 */
+(CXCursorObjC *)nullCursor;
//@property (nonatomic, readonly, strong) CXCursorObjC *nullCursor;
//CINDEX_LINKAGE CXCursor clang_getNullCursor(void);

/**
 * \brief Retrieve the cursor that represents the given translation unit.
 *
 * The translation unit cursor can be used to start traversing the
 * various declarations within the given translation unit.
 */
//CINDEX_LINKAGE CXCursor clang_getTranslationUnitCursor(CXTranslationUnit);

/**
 * \brief Determine whether two cursors are equivalent.
 */
-(BOOL)equalCursors:(CXCursorObjC*) thisCursor;
//CINDEX_LINKAGE unsigned clang_equalCursors(CXCursor, CXCursor);

/**
 * \brief Returns non-zero if \p cursor is null.
 */
@property (nonatomic, readonly) BOOL isNull;
//CINDEX_LINKAGE int clang_Cursor_isNull(CXCursor cursor);

/**
 * \brief Compute a hash value for the given cursor.
 */
//@property (nonatomic, readonly) unsigned long *hashCursor;
//CINDEX_LINKAGE unsigned clang_hashCursor(CXCursor);

/**
 * \brief Retrieve the kind of the given cursor.
 */
@property (nonatomic, readonly) enum CXCursorKind cursorKind;
//CINDEX_LINKAGE enum CXCursorKind clang_getCursorKind(CXCursor);


/**
 * \brief Determine the linkage of the entity referred to by a given cursor.
 */
//CINDEX_LINKAGE enum CXLinkageKind clang_getCursorLinkage(CXCursor cursor);

/**
 * \brief Determine the availability of the entity that this cursor refers to,
 * taking the current target platform into account.
 *
 * \param cursor The cursor to query.
 *
 * \returns The availability of the cursor.
 */
@property (nonatomic, readonly) enum CXAvailabilityKind cursorAvailability;
//CINDEX_LINKAGE enum CXAvailabilityKind clang_getCursorAvailability(CXCursor cursor);

/**
 * \brief Determine the availability of the entity that this cursor refers to
 * on any platforms for which availability information is known.
 *
 * \param cursor The cursor to query.
 *
 * \param always_deprecated If non-NULL, will be set to indicate whether the
 * entity is deprecated on all platforms.
 *
 * \param deprecated_message If non-NULL, will be set to the message text
 * provided along with the unconditional deprecation of this entity. The client
 * is responsible for deallocating this string.
 *
 * \param always_unavailable If non-NULL, will be set to indicate whether the
 * entity is unavailable on all platforms.
 *
 * \param unavailable_message If non-NULL, will be set to the message text
 * provided along with the unconditional unavailability of this entity. The
 * client is responsible for deallocating this string.
 *
 * \param availability If non-NULL, an array of CXPlatformAvailability instances
 * that will be populated with platform availability information, up to either
 * the number of platforms for which availability information is available (as
 * returned by this function) or \c availability_size, whichever is smaller.
 *
 * \param availability_size The number of elements available in the
 * \c availability array.
 *
 * \returns The number of platforms (N) for which availability information is
 * available (which is unrelated to \c availability_size).
 *
 * Note that the client is responsible for calling
 * \c clang_disposeCXPlatformAvailability to free each of the
 * platform-availability structures returned. There are
 * \c min(N, availability_size) such structures.
 */
//CINDEX_LINKAGE int
//clang_getCursorPlatformAvailability(CXCursor cursor,
//                                    int *always_deprecated,
 //                                   CXString *deprecated_message,
 //                                   int *always_unavailable,
  //                                  CXString *unavailable_message,
   //                                 CXPlatformAvailability *availability,
    //                                int availability_size);


/**
 * \brief Determine the "language" of the entity referred to by a given cursor.
 */
//CINDEX_LINKAGE enum CXLanguageKind clang_getCursorLanguage(CXCursor cursor);

/**
 * \brief Returns the translation unit that a cursor originated from.
 */
//CINDEX_LINKAGE CXTranslationUnit clang_Cursor_getTranslationUnit(CXCursor);

/**
 * \brief Determine the semantic parent of the given cursor.
 *
 * The semantic parent of a cursor is the cursor that semantically contains
 * the given \p cursor. For many declarations, the lexical and semantic parents
 * are equivalent (the lexical parent is returned by
 * \c clang_getCursorLexicalParent()). They diverge when declarations or
 * definitions are provided out-of-line. For example:
 *
 * \code
 * class C {
 *  void f();
 * };
 *
 * void C::f() { }
 * \endcode
 *
 * In the out-of-line definition of \c C::f, the semantic parent is the
 * the class \c C, of which this function is a member. The lexical parent is
 * the place where the declaration actually occurs in the source code; in this
 * case, the definition occurs in the translation unit. In general, the
 * lexical parent for a given entity can change without affecting the semantics
 * of the program, and the lexical parent of different declarations of the
 * same entity may be different. Changing the semantic parent of a declaration,
 * on the other hand, can have a major impact on semantics, and redeclarations
 * of a particular entity should all have the same semantic context.
 *
 * In the example above, both declarations of \c C::f have \c C as their
 * semantic context, while the lexical context of the first \c C::f is \c C
 * and the lexical context of the second \c C::f is the translation unit.
 *
 * For global declarations, the semantic parent is the translation unit.
 */
@property (nonatomic, strong, readonly) CXCursorObjC *cursorSemanticParent;
//CINDEX_LINKAGE CXCursor clang_getCursorSemanticParent(CXCursor cursor);

/**
 * \brief Determine the lexical parent of the given cursor.
 *
 * The lexical parent of a cursor is the cursor in which the given \p cursor
 * was actually written. For many declarations, the lexical and semantic parents
 * are equivalent (the semantic parent is returned by
 * \c clang_getCursorSemanticParent()). They diverge when declarations or
 * definitions are provided out-of-line. For example:
 *
 * \code
 * class C {
 *  void f();
 * };
 *
 * void C::f() { }
 * \endcode
 *
 * In the out-of-line definition of \c C::f, the semantic parent is the
 * the class \c C, of which this function is a member. The lexical parent is
 * the place where the declaration actually occurs in the source code; in this
 * case, the definition occurs in the translation unit. In general, the
 * lexical parent for a given entity can change without affecting the semantics
 * of the program, and the lexical parent of different declarations of the
 * same entity may be different. Changing the semantic parent of a declaration,
 * on the other hand, can have a major impact on semantics, and redeclarations
 * of a particular entity should all have the same semantic context.
 *
 * In the example above, both declarations of \c C::f have \c C as their
 * semantic context, while the lexical context of the first \c C::f is \c C
 * and the lexical context of the second \c C::f is the translation unit.
 *
 * For declarations written in the global scope, the lexical parent is
 * the translation unit.
 */
@property (nonatomic, strong, readonly) CXCursorObjC *cursorLexicalParent;
//CINDEX_LINKAGE CXCursor clang_getCursorLexicalParent(CXCursor cursor);

/**
 * \brief Determine the set of methods that are overridden by the given
 * method.
 *
 * In both Objective-C and C++, a method (aka virtual member function,
 * in C++) can override a virtual method in a base class. For
 * Objective-C, a method is said to override any method in the class's
 * base class, its protocols, or its categories' protocols, that has the same
 * selector and is of the same kind (class or instance).
 * If no such method exists, the search continues to the class's superclass,
 * its protocols, and its categories, and so on. A method from an Objective-C
 * implementation is considered to override the same methods as its
 * corresponding method in the interface.
 *
 * For C++, a virtual member function overrides any virtual member
 * function with the same signature that occurs in its base
 * classes. With multiple inheritance, a virtual member function can
 * override several virtual member functions coming from different
 * base classes.
 *
 * In all cases, this function determines the immediate overridden
 * method, rather than all of the overridden methods. For example, if
 * a method is originally declared in a class A, then overridden in B
 * (which in inherits from A) and also in C (which inherited from B),
 * then the only overridden method returned from this function when
 * invoked on C's method will be B's method. The client may then
 * invoke this function again, given the previously-found overridden
 * methods, to map out the complete method-override set.
 *
 * \param cursor A cursor representing an Objective-C or C++
 * method. This routine will compute the set of methods that this
 * method overrides.
 *
 * \param overridden A pointer whose pointee will be replaced with a
 * pointer to an array of cursors, representing the set of overridden
 * methods. If there are no overridden methods, the pointee will be
 * set to NULL. The pointee must be freed via a call to
 * \c clang_disposeOverriddenCursors().
 *
 * \param num_overridden A pointer to the number of overridden
 * functions, will be set to the number of overridden functions in the
 * array pointed to by \p overridden.
 */
//CINDEX_LINKAGE void clang_getOverriddenCursors(CXCursor cursor,
//                                               CXCursor **overridden,
//                                               unsigned *num_overridden);

/**
 * \brief Free the set of overridden cursors returned by \c
 * clang_getOverriddenCursors().
 */
//CINDEX_LINKAGE void clang_disposeOverriddenCursors(CXCursor *overridden);

/**
 * \brief Retrieve the file that is included by the given inclusion directive
 * cursor.
 */
@property (nonatomic, strong, readonly) CXFileObjC *includedFile;
//CINDEX_LINKAGE CXFile clang_getIncludedFile(CXCursor cursor);

/**
 * \brief Retrieve the type of a CXCursor (if any).
 */
@property (nonatomic, strong, readonly) CXTypeObjC *cursorType;
//CINDEX_LINKAGE CXType clang_getCursorType(CXCursor C);

/**
 * \brief Retrieve the underlying type of a typedef declaration.
 *
 * If the cursor does not reference a typedef declaration, an invalid type is
 * returned.
 */
@property (nonatomic, strong, readonly) CXTypeObjC *typedefDeclUnderlyingType;
//CINDEX_LINKAGE CXType clang_getTypedefDeclUnderlyingType(CXCursor C);

/**
 * \brief Retrieve the integer type of an enum declaration.
 *
 * If the cursor does not reference an enum declaration, an invalid type is
 * returned.
 */
@property (nonatomic, strong, readonly) CXTypeObjC *enumDeclIntegerType;
//CINDEX_LINKAGE CXType clang_getEnumDeclIntegerType(CXCursor C);

/**
 * \brief Retrieve the integer value of an enum constant declaration as a signed
 *  long long.
 *
 * If the cursor does not reference an enum constant declaration, LLONG_MIN is returned.
 * Since this is also potentially a valid constant value, the kind of the cursor
 * must be verified before calling this function.
 */
@property (nonatomic, readonly) long long enumConstantDeclValue;
//CINDEX_LINKAGE long long clang_getEnumConstantDeclValue(CXCursor C);

/**
 * \brief Retrieve the integer value of an enum constant declaration as an unsigned
 *  long long.
 *
 * If the cursor does not reference an enum constant declaration, ULLONG_MAX is returned.
 * Since this is also potentially a valid constant value, the kind of the cursor
 * must be verified before calling this function.
 */
@property (nonatomic, readonly) unsigned long long enumConstantDeclUnsignedValue;
//CINDEX_LINKAGE unsigned long long clang_getEnumConstantDeclUnsignedValue(CXCursor C);

/**
 * \brief Retrieve the bit width of a bit field declaration as an integer.
 *
 * If a cursor that is not a bit field declaration is passed in, -1 is returned.
 */
//CINDEX_LINKAGE int clang_getFieldDeclBitWidth(CXCursor C);

/**
 * \brief Retrieve the number of non-variadic arguments associated with a given
 * cursor.
 *
 * The number of arguments can be determined for calls as well as for
 * declarations of functions or methods. For other cursors -1 is returned.
 */
@property (nonatomic, readonly) NSInteger numArguments;
//CINDEX_LINKAGE int clang_Cursor_getNumArguments(CXCursor C);

/**
 * \brief Retrieve the argument cursor of a function or method.
 *
 * The argument cursor can be determined for calls as well as for declarations
 * of functions or methods. For other cursors and for invalid indices, an
 * invalid cursor is returned.
 */
-(CXCursorObjC*) getArgument:(NSUInteger) i;
//CINDEX_LINKAGE CXCursor clang_Cursor_getArgument(CXCursor C, unsigned i);

/**
 * Returns the Objective-C type encoding for the specified declaration.
 */
@property (nonatomic, readonly, strong) NSString *declObjCTypeEncoding;
//CINDEX_LINKAGE CXString clang_getDeclObjCTypeEncoding(CXCursor C);

/**
 * \brief Retrieve the return type associated with a given cursor.
 *
 * This only returns a valid type if the cursor refers to a function or method.
 */
@property (nonatomic, readonly, strong) CXTypeObjC *cursorResultType;
//CINDEX_LINKAGE CXType clang_getCursorResultType(CXCursor C);


/**
 * \brief Returns non-zero if the cursor specifies a Record member that is a
 *   bitfield.
 */
@property (nonatomic, readonly) BOOL isBitField;
//CINDEX_LINKAGE unsigned clang_Cursor_isBitField(CXCursor C);

/**
 * \brief Returns 1 if the base class specified by the cursor with kind
 *   CX_CXXBaseSpecifier is virtual.
 */
@property (nonatomic, readonly) BOOL isVirtualBase;
//CINDEX_LINKAGE unsigned clang_isVirtualBase(CXCursor);

/**
 * \brief Represents the C++ access control level to a base class for a
 * cursor with kind CX_CXXBaseSpecifier.
 */
//enum CX_CXXAccessSpecifier {
//    CX_CXXInvalidAccessSpecifier,
//    CX_CXXPublic,
//    CX_CXXProtected,
//    CX_CXXPrivate
//};

/**
 * \brief Returns the access control level for the referenced object.
 *
 * If the cursor refers to a C++ declaration, its access control level within its
 * parent scope is returned. Otherwise, if the cursor refers to a base specifier or
 * access specifier, the specifier itself is returned.
 */
//CINDEX_LINKAGE enum CX_CXXAccessSpecifier clang_getCXXAccessSpecifier(CXCursor);

/**
 * \brief Determine the number of overloaded declarations referenced by a
 * \c CXCursor_OverloadedDeclRef cursor.
 *
 * \param cursor The cursor whose overloaded declarations are being queried.
 *
 * \returns The number of overloaded declarations referenced by \c cursor. If it
 * is not a \c CXCursor_OverloadedDeclRef cursor, returns 0.
 */
//CINDEX_LINKAGE unsigned clang_getNumOverloadedDecls(CXCursor cursor);

/**
 * \brief Retrieve a cursor for one of the overloaded declarations referenced
 * by a \c CXCursor_OverloadedDeclRef cursor.
 *
 * \param cursor The cursor whose overloaded declarations are being queried.
 *
 * \param index The zero-based index into the set of overloaded declarations in
 * the cursor.
 *
 * \returns A cursor representing the declaration referenced by the given
 * \c cursor at the specified \c index. If the cursor does not have an
 * associated set of overloaded declarations, or if the index is out of bounds,
 * returns \c clang_getNullCursor();
 */
//CINDEX_LINKAGE CXCursor clang_getOverloadedDecl(CXCursor cursor,
//                                                unsigned index);

/**
 * \brief For cursors representing an iboutletcollection attribute,
 *  this function returns the collection element type.
 *
 */
//CINDEX_LINKAGE CXType clang_getIBOutletCollectionType(CXCursor);



/**
 * \brief Visitor invoked for each cursor found by a traversal.
 *
 * This visitor function will be invoked for each cursor found by
 * clang_visitCursorChildren(). Its first argument is the cursor being
 * visited, its second argument is the parent visitor for that cursor,
 * and its third argument is the client data provided to
 * clang_visitCursorChildren().
 *
 * The visitor should return one of the \c CXChildVisitResult values
 * to direct clang_visitCursorChildren().
 */
//typedef enum CXChildVisitResult (*CXCursorVisitor)(CXCursor cursor,
//CXCursor parent,
//CXClientData client_data);
/**
 * \brief Visit the children of a particular cursor.
 *
 * This function visits all the direct children of the given cursor,
 * invoking the given \p visitor function with the cursors of each
 * visited child. The traversal may be recursive, if the visitor returns
 * \c CXChildVisit_Recurse. The traversal may also be ended prematurely, if
 * the visitor returns \c CXChildVisit_Break.
 *
 * \param parent the cursor whose child may be visited. All kinds of
 * cursors can be visited, including invalid cursors (which, by
 * definition, have no children).
 *
 * \param visitor the visitor function that will be invoked for each
 * child of \p parent.
 *
 * \param client_data pointer data supplied by the client, which will
 * be passed to the visitor each time it is invoked.
 *
 * \returns a non-zero value if the traversal was terminated
 * prematurely by the visitor returning \c CXChildVisit_Break.
 */
//CINDEX_LINKAGE unsigned clang_visitChildren(CXCursor parent,
//                                            CXCursorVisitor visitor,
//                                            CXClientData client_data);

#ifdef __has_feature
#  if __has_feature(blocks)
/**
 * \brief Visitor invoked for each cursor found by a traversal.
 *
 * This visitor block will be invoked for each cursor found by
 * clang_visitChildrenWithBlock(). Its first argument is the cursor being
 * visited, its second argument is the parent visitor for that cursor.
 *
 * The visitor should return one of the \c CXChildVisitResult values
 * to direct clang_visitChildrenWithBlock().
 */
typedef enum CXChildVisitResult (^CXCursorObjCVisitorBlock)(CXCursorObjC *cursor, CXCursorObjC *parent);

/**
 * Visits the children of a cursor using the specified block.  Behaves
 * identically to clang_visitChildren() in all other respects.
 */
-(BOOL)visitChildrenWithBlock:(CXCursorObjCVisitorBlock) block;
//unsigned clang_visitChildrenWithBlock(CXCursor parent,
//                                      CXCursorVisitorBlock block);
#  endif
#endif

/**
 * \defgroup CINDEX_CURSOR_XREF Cross-referencing in the AST
 *
 * These routines provide the ability to determine references within and
 * across translation units, by providing the names of the entities referenced
 * by cursors, follow reference cursors to the declarations they reference,
 * and associate declarations with their definitions.
 *
 * @{
 */

/**
 * \brief Retrieve a Unified Symbol Resolution (USR) for the entity referenced
 * by the given cursor.
 *
 * A Unified Symbol Resolution (USR) is a string that identifies a particular
 * entity (function, class, variable, etc.) within a program. USRs can be
 * compared across translation units to determine, e.g., when references in
 * one translation refer to an entity defined in another translation unit.
 */
@property (nonatomic, readonly) NSString *cursorUSR;
//CINDEX_LINKAGE CXString clang_getCursorUSR(CXCursor);

/**
 * \brief Retrieve a range for a piece that forms the cursors spelling name.
 * Most of the times there is only one range for the complete spelling but for
 * objc methods and objc message expressions, there are multiple pieces for each
 * selector identifier.
 *
 * \param pieceIndex the index of the spelling name piece. If this is greater
 * than the actual number of pieces, it will return a NULL (invalid) range.
 *
 * \param options Reserved.
 */
//CINDEX_LINKAGE CXSourceRange clang_Cursor_getSpellingNameRange(CXCursor,
//                                                               unsigned pieceIndex,
//                                                               unsigned options);

/**
 * \brief Retrieve the display name for the entity referenced by this cursor.
 *
 * The display name contains extra information that helps identify the cursor,
 * such as the parameters of a function or template or the arguments of a
 * class template specialization.
 */
@property (nonatomic, readonly) NSString *cursorDisplayName;
//CINDEX_LINKAGE CXString clang_getCursorDisplayName(CXCursor);



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
@property (nonatomic, readonly, strong) CXCursorObjC *cursorReferenced;
//CINDEX_LINKAGE CXCursor clang_getCursorReferenced(CXCursor);

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
@property (nonatomic, readonly, strong) CXCursorObjC *cursorDefinition;
//CINDEX_LINKAGE CXCursor clang_getCursorDefinition(CXCursor);

/**
 * \brief Determine whether the declaration pointed to by this cursor
 * is also a definition of that entity.
 */
@property (nonatomic, readonly) BOOL isCursorDefinition;
//CINDEX_LINKAGE unsigned clang_isCursorDefinition(CXCursor);

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
@property (nonatomic, readonly, strong) CXCursorObjC *canonicalCursor;
//CINDEX_LINKAGE CXCursor clang_getCanonicalCursor(CXCursor);


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
@property (nonatomic, readonly) NSInteger objCSelectorIndex;
//CINDEX_LINKAGE int clang_Cursor_getObjCSelectorIndex(CXCursor);

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
@property (nonatomic, readonly) BOOL isDynamicCall;
//CINDEX_LINKAGE int clang_Cursor_isDynamicCall(CXCursor C);

/**
 * \brief Given a cursor pointing to an ObjC message, returns the CXType of the
 * receiver.
 */
@property (nonatomic, readonly, strong) CXTypeObjC *receiverType;
//CINDEX_LINKAGE CXType clang_Cursor_getReceiverType(CXCursor C);

/**
 * \brief Given a cursor that represents a property declaration, return the
 * associated property attributes. The bits are formed from
 * \c CXObjCPropertyAttrKind.
 *
 * \param reserved Reserved for future use, pass 0.
 */
-(NSUInteger)objCPropertyAttributes;
//CINDEX_LINKAGE unsigned clang_Cursor_getObjCPropertyAttributes(CXCursor C,
//                                                               unsigned reserved);

/**
 * \brief Given a cursor that represents an ObjC method or parameter
 * declaration, return the associated ObjC qualifiers for the return type or the
 * parameter respectively. The bits are formed from CXObjCDeclQualifierKind.
 */
@property (nonatomic, readonly) NSInteger objCDeclQualifiers;
//CINDEX_LINKAGE unsigned clang_Cursor_getObjCDeclQualifiers(CXCursor C);

/**
 * \brief Given a cursor that represents an ObjC method or property declaration,
 * return non-zero if the declaration was affected by "@optional".
 * Returns zero if the cursor is not such a declaration or it is "@required".
 */
@property (nonatomic, readonly) BOOL isObjCOptional;
//CINDEX_LINKAGE unsigned clang_Cursor_isObjCOptional(CXCursor C);

/**
 * \brief Returns non-zero if the given cursor is a variadic function or method.
 */
@property (nonatomic, readonly) BOOL isVariadic;
//CINDEX_LINKAGE unsigned clang_Cursor_isVariadic(CXCursor C);

/**
 * \brief Given a cursor that represents a declaration, return the associated
 * comment's source range.  The range may include multiple consecutive comments
 * with whitespace in between.
 */
//CINDEX_LINKAGE CXSourceRange clang_Cursor_getCommentRange(CXCursor C);

/**
 * \brief Given a cursor that represents a declaration, return the associated
 * comment text, including comment markers.
 */
@property (nonatomic, readonly, strong) NSString *rawCommentText;
//CINDEX_LINKAGE CXString clang_Cursor_getRawCommentText(CXCursor C);

/**
 * \brief Given a cursor that represents a documentable entity (e.g.,
 * declaration), return the associated \\brief paragraph; otherwise return the
 * first paragraph.
 */
@property (nonatomic, readonly, strong) NSString *briefCommentText;
//CINDEX_LINKAGE CXString clang_Cursor_getBriefCommentText(CXCursor C);

/**
 * \brief Given a cursor that represents a documentable entity (e.g.,
 * declaration), return the associated parsed comment as a
 * \c CXComment_FullComment AST node.
 */
//CINDEX_LINKAGE CXComment clang_Cursor_getParsedComment(CXCursor C);
@property (nonatomic, readonly, strong)CXCommentObjC *parsedComment;

/**
 * \brief Given a CXCursor_ModuleImportDecl cursor, return the associated module.
 */
//CINDEX_LINKAGE CXModule clang_Cursor_getModule(CXCursor C);

/**
 * \brief Determine if a C++ member function or member function template is
 * pure virtual.
 */
@property (nonatomic, readonly) BOOL isPureVirtual;
//CINDEX_LINKAGE unsigned clang_CXXMethod_isPureVirtual(CXCursor C);

/**
 * \brief Determine if a C++ member function or member function template is
 * declared 'static'.
 */
@property (nonatomic, readonly) BOOL isStatic;
//CINDEX_LINKAGE unsigned clang_CXXMethod_isStatic(CXCursor C);

/**
 * \brief Determine if a C++ member function or member function template is
 * explicitly declared 'virtual' or if it overrides a virtual method from
 * one of the base classes.
 */
@property (nonatomic, readonly) BOOL isVirtual;
//CINDEX_LINKAGE unsigned clang_CXXMethod_isVirtual(CXCursor C);

/**
 * \brief Given a cursor that represents a template, determine
 * the cursor kind of the specializations would be generated by instantiating
 * the template.
 *
 * This routine can be used to determine what flavor of function template,
 * class template, or class template partial specialization is stored in the
 * cursor. For example, it can describe whether a class template cursor is
 * declared with "struct", "class" or "union".
 *
 * \param C The cursor to query. This cursor should represent a template
 * declaration.
 *
 * \returns The cursor kind of the specializations that would be generated
 * by instantiating the template \p C. If \p C is not a template, returns
 * \c CXCursor_NoDeclFound.
 */
//CINDEX_LINKAGE enum CXCursorKind clang_getTemplateCursorKind(CXCursor C);

/**
 * \brief Given a cursor that may represent a specialization or instantiation
 * of a template, retrieve the cursor that represents the template that it
 * specializes or from which it was instantiated.
 *
 * This routine determines the template involved both for explicit
 * specializations of templates and for implicit instantiations of the template,
 * both of which are referred to as "specializations". For a class template
 * specialization (e.g., \c std::vector<bool>), this routine will return
 * either the primary template (\c std::vector) or, if the specialization was
 * instantiated from a class template partial specialization, the class template
 * partial specialization. For a class template partial specialization and a
 * function template specialization (including instantiations), this
 * this routine will return the specialized template.
 *
 * For members of a class template (e.g., member functions, member classes, or
 * static data members), returns the specialized or instantiated member.
 * Although not strictly "templates" in the C++ language, members of class
 * templates have the same notions of specializations and instantiations that
 * templates do, so this routine treats them similarly.
 *
 * \param C A cursor that may be a specialization of a template or a member
 * of a template.
 *
 * \returns If the given cursor is a specialization or instantiation of a
 * template or a member thereof, the template or member that it specializes or
 * from which it was instantiated. Otherwise, returns a NULL cursor.
 */
@property (nonatomic, readonly, strong) CXCursorObjC *specializedCursorTemplate;
//CINDEX_LINKAGE CXCursor clang_getSpecializedCursorTemplate(CXCursor C);

/**
 * \brief Given a cursor that references something else, return the source range
 * covering that reference.
 *
 * \param C A cursor pointing to a member reference, a declaration reference, or
 * an operator call.
 * \param NameFlags A bitset with three independent flags:
 * CXNameRange_WantQualifier, CXNameRange_WantTemplateArgs, and
 * CXNameRange_WantSinglePiece.
 * \param PieceIndex For contiguous names or when passing the flag
 * CXNameRange_WantSinglePiece, only one piece with index 0 is
 * available. When the CXNameRange_WantSinglePiece flag is not passed for a
 * non-contiguous names, this index can be used to retrieve the individual
 * pieces of the name. See also CXNameRange_WantSinglePiece.
 *
 * \returns The piece of the name pointed to by the given cursor. If there is no
 * name, or if the PieceIndex is out-of-range, a null-cursor will be returned.
 */
//CINDEX_LINKAGE CXSourceRange clang_getCursorReferenceNameRange(CXCursor C,
//                                                               unsigned NameFlags,
//                                                               unsigned PieceIndex);

/**
 * \brief Retrieve a name for the entity referenced by this cursor.
 */
@property (nonatomic, readonly, strong) NSString *cursorSpelling;
//CINDEX_LINKAGE CXString clang_getCursorSpelling(CXCursor);

//---------------------------------------------------------------------------------
-(void)enumerateMethodDecl:(void (^)(BOOL isClassMethod,
                                     BOOL isIntanceMethod,
                                     NSString *name,
                                     NSString *briefComment,
                                     NSString *rawComment,
                                     NSUInteger numParamaters
                                     ))overviewBlock
                    result:(void (^)(BOOL isVoid,
                                     NSString *returnName,
                                     CXTypeObjC *returnType
                                     ))resultBlock
                 paramater:(void (^)(NSString *paramaterName,
                                     NSString *paramaterTypeAsString,
                                     NSString *briefComment,
                                     NSString *rawComment,
                                     CXTypeObjC *paramaterType,
                                     NSString *methodNameForParamater
                                     ))paramaterBlock;

@end





