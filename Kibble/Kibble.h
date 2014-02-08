//
//  Kibble.h
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMObject.h"

@class KibbleType;


@interface Kibble : NSObject
@property (nonatomic, strong) KibbleType *kibbleType; // aka class, aka datemodel in MVC
@property (nonatomic, copy) NSString *name; // name of this kibble object
@property (nonatomic, strong, readonly) NSString *kibbleDescription; // description of this kibble object
@property (nonatomic, strong) id imageForEditor; // visual representation of this Kibble
@property (nonatomic, strong) id content; // the content of the kibble

// creation of instance classes
+(id)createNewKibbleInstance;
+(id)createNewKibbleInstanceWithName:(NSString*)name;
+(id)createNewKibbleInstanceContaining:(id)thisContent;
+(id)createNewKibbleInstanceWithName:(NSString*)name containing:(id)thisContent;


@end

@interface Kibble (private)


-(id)initWithKibbleType:(KibbleType *)thisKibbleType; // USE THE KibbleType to create new kibble instances
    
    
@end