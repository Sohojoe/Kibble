//
//  CXCommentObjC+Private.m
//  ObjectiveBrowser
//
//  Created by Joe on 3/8/14.
//
//

#import "CXCommentObjC+Private.h"

@implementation CXCommentObjC (Private)
@dynamic comment;
+(CXCommentObjC *)commentFrom:(CXComment) thisComment{
    CXCommentObjC * c = [[CXCommentObjC alloc]initWith:thisComment];
    return c;
}
-(CXCommentObjC *)initWith:(CXComment) thisComment{
    self = [super init];
    if (self) {
        self.comment = thisComment;
    }
    return self;
}

@end
