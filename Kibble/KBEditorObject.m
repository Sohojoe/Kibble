//
//  KBEditorObject.m
//  Kibble
//
//  Created by Joe on 4/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KBEditorObject.h"

#define kDone @"DONE"
#define kPlus @"+"
#define kFromInput @"FROM\nINPUT"

@implementation KBEditorObject

+(instancetype)editorObject{
    KBEditorObject *o = [self new];
    return o;
}
+(instancetype)editorObjectDone{
    KBEditorObject *o = [self editorObjectWithName:kDone];
    return o;}
-(BOOL)isTypeDone{
    BOOL res = ([self.name isEqualToString:kDone] == NSOrderedSame);
    return res;}
+(instancetype)editorObjectPlus{
    KBEditorObject *o = [self editorObjectWithName:kPlus];
    return o;}
-(BOOL)isTypePlus{
    BOOL res = ([self.name isEqualToString:kPlus] == NSOrderedSame);
    return res;}
+(instancetype)editorObjectFromInput{
    KBEditorObject *o = [self editorObjectWithName:kFromInput];
    return o;}
-(BOOL)isTypeFromInput{
    BOOL res = ([self.name isEqualToString:kFromInput]);
    return res;}

+(instancetype)editorObjectWithName:(NSString*)aName{
    KBEditorObject *o = [self editorObject];
    o.name = aName;
    return o;
}
-(NSString*)description{
    return self.name;
}
-(NSString*)debugDescription{
    return self.name;
}
@end

/*
@implementation KBEditorObjectDone : KBEditorObject
+(instancetype)editorObject{
    KBEditorObjectDone *o = [super editorObject];
    o.name = @"DONE";
    return o;
}
@end

@implementation KBEditorObjectPlus : KBEditorObject
+(instancetype)editorObject{
    KBEditorObjectPlus *o = [super editorObject];
    o.name = @"+";
    return o;
}
@end
 */
