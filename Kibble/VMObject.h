//
//  VMObject.h
//  Kibble
//
//  Created by Joe on 2/7/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;


// This is the core VM object class, every kibble class that is VM must use this

@protocol VMObjectExport <JSExport>
@property (nonatomic, strong) NSString *name;                 // the name of the object
@property (nonatomic, strong) NSString *description;    // the description of the object
@end

@interface VMObject : NSObject <VMObjectExport>

// creation of instance classes
+(id)createNewKibbleInstance;
+(id)createNewKibbleInstanceWithName:(NSString*)name;
+(id)createNewKibbleInstanceContaining:(id)thisContent;
+(id)createNewKibbleInstanceWithName:(NSString*)name containing:(id)thisContent;


@end
