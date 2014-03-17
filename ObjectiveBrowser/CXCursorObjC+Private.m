//
//  CXCursorObjC+Private.m
//  ObjectiveBrowser
//
//  Created by Joe on 3/8/14.
//
//

#import "CXCursorObjC+Private.h"

@implementation CXCursorObjC (Private)
@dynamic cursor;
+(CXCursorObjC *)cursorFrom:(CXCursor) thisCursor{
    CXCursorObjC * cursorObjC = [[CXCursorObjC alloc]initWith:thisCursor];
    return cursorObjC;
}
-(CXCursorObjC *)initWith:(CXCursor) thisCursor{
    self = [super init];
    if (self) {
        self.cursor = thisCursor;
    }
    return self;
}


@end
