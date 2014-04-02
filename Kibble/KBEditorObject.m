//
//  KBEditorObject.m
//  Kibble
//
//  Created by Joe on 4/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KBEditorObject.h"

@implementation KBEditorObject

+(instancetype)editorObject{
    KBEditorObject *o = [self new];
    return o;
}
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
