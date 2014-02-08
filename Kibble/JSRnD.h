//
//  JSRnD.h
//  Kibble
//
//  Created by Joe on 2/6/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;

//@protocol ThingJSExports <JSExport>
//@property (nonatomic, copy) NSString *name;
//@end

@interface JSRnD : NSObject <JSExport>
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger number;

@end
