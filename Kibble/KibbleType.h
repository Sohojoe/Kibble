//
//  KibbleType.h
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KibbleType : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *parent;
@property (nonatomic, strong) NSMutableArray *uncles;   // lists of protocols I dear too
@property (nonatomic, strong) id image; // visual representation of this Kibble
//--
@property (nonatomic, strong) NSMutableArray *friends; // list of types (classes) I can talk to
@property (nonatomic, strong) NSMutableArray *kibbleTalkConversations; // aka public functions
@property (nonatomic, strong) NSMutableArray *kibbleTalkVars; // aka public variables
@property (nonatomic, strong) NSMutableArray *secretKibbleTalkConversations; // aka private functions
@property (nonatomic, strong) NSMutableArray *secretKibbleTalkVars; // aka private variables
@property (nonatomic) BOOL isAHelperKibble;  // aka singleton
//--
@property (nonatomic, strong, readonly) KibbleType *mayor; // Mayor of this class, aka class vars, functions, statics, etc
//-- helper
@property (nonatomic, strong) NSString *description;

+(id)type;



-(KibbleType*)initWithName:(NSString*)thisName parent:(NSString*)thisParent description:(NSString*)thisDescription;



@end
