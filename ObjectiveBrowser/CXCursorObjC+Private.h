//
//  CXCursorObjC+Private.h
//  ObjectiveBrowser
//
//  Created by Joe on 3/8/14.
//
//

#import "CXCursorObjC.h"
#import <clang-c/Index.h>

@interface CXCursorObjC (Private)
@property (nonatomic) CXCursor cursor;
+(CXCursorObjC *)cursorFrom:(CXCursor) thisCursor;
-(CXCursorObjC *)initWith:(CXCursor) thisCursor;
@end
