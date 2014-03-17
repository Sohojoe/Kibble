//
//  FilesToIndex.h
//  ObjectiveBrowser
//
//  Created by Joe on 3/8/14.
//
//

#import <Foundation/Foundation.h>
//#import <SpriteKit/SpriteKit.h>
//#import <clang-c/Index.h>
//#import "CXCursorObjC.h"
//#import "CXTypeObjC.h"
//#import "CXCommentObjC.h"

//#import <Foundation/

@class randomTypedClass;
@class NSString;
@interface AAString : NSObject

+(NSString*)stringWithString:(NSString*)string;

/**
 * \brief Creates ObjectiveC class wrapper around CXCursor
 *
 * \param ptrToThisCursorComment The cursor to wrap.
 *
 * \param inter a integer that we just love.
 *
 * \param ourClass the third paramater.
 *
 * \returns The ObjectiveC object.
 */
+(int)cursorFromPointer:(void *)ptrToThisCursor with:(int)interEEE andObject:(randomTypedClass*)ourClass;
@property (nonatomic, weak) id prop1;
@property (nonatomic, strong) id prop1b;
@property (nonatomic, strong, readonly) id prop2;


@end
#import <Foundation/Foundation.h>
