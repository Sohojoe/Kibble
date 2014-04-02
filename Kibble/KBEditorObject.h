//
//  KBEditorObject.h
//  Kibble
//
//  Created by Joe on 4/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBEditorObject : NSObject
@property (nonatomic, strong) NSString* name;
+(instancetype)editorObject;
+(instancetype)editorObjectWithName:(NSString*)aName;
@end

@interface KBEditorObjectDone : KBEditorObject
@end

@interface KBEditorObjectPlus : KBEditorObject
@end
