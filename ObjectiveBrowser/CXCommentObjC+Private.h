//
//  CXCommentObjC+Private.h
//  ObjectiveBrowser
//
//  Created by Joe on 3/8/14.
//
//

#import "CXCommentObjC.h"
#import <clang-c/Index.h>

@interface CXCommentObjC (Private)
@property (nonatomic) CXComment comment;
+(CXCommentObjC *)commentFrom:(CXComment) thisComment;
-(CXCommentObjC *)initWith:(CXComment) thisComment;

@end
