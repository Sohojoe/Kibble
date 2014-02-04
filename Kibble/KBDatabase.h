//
//  KBDatabase.h
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KibbleType.h"

@interface KBDatabase : NSObject
+(KBDatabase *)aDatabase;  // active database aka singleton

-(id)databaseEntryForKey:(NSString*)key forDataType:(id)dataType;
-(void)databaseAddEntry:(id)entry forKey:(NSString*)key;
-(void)enumerateDatabaseKeysForDataType:(id)dataType withBlock:(void (^)(id key))block;

// convience functions
-(id)kibbleTypeElseLazyInitForKey:(Class)thisKibbleType;

@end
