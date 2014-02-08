//
//  JSWrapper.h
//  Kibble
//
//  Created by Joe on 2/6/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;

@protocol JSConform <JSExport>
@property (nonatomic, copy) NSString *name;
@end
@interface JSprototype : NSObject <JSConform>
@property (nonatomic, copy) NSString *name;
@end


@interface JS : NSObject

+(JS *)activeJS;                    // the singleton
+(JSContext *)vM;                    // the vertual machine

-(void)addClass:(id)thisClass;


@end
