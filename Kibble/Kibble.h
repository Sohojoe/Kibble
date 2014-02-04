//
//  Kibble.h
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KibbleType.h"

@interface Kibble : UIButton
@property (nonatomic, strong) KibbleType *kibbleType; // aka class, aka datemodel in MVC
@property (nonatomic, strong) NSString *name; // name of this kibble object
@property (nonatomic, strong) NSString *description; // description of this kibble object
@property (nonatomic, strong) id imageForEditor; // visual representation of this Kibble
@property (nonatomic, strong) id content; // the content of the kibble



@end

@interface Kibble (private)


-(id)initWithKibbleType:(KibbleType *)thisKibbleType; // USE THE KibbleType to create new kibble instances
    
    
@end