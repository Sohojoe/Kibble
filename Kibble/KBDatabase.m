//
//  KBDatabase.m
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KBDatabase.h"

@interface KBDatabaseObject : NSObject
@property (nonatomic, strong) id objectType;
@property (nonatomic, strong) NSString *objectName;
@property (nonatomic, strong) NSDate *timeStamp;
@property (nonatomic, strong) NSMutableDictionary *objects;
@end @implementation KBDatabaseObject @end

@interface KBDatabase ()
@property (nonatomic, strong) NSMutableDictionary *databaseObjects;

@end

@implementation KBDatabase

+(KBDatabase*)aDatabase{
    static KBDatabase *shared = nil;
    
    if (shared==nil) {
        // first Time Init
        shared = [[super allocWithZone:NULL] init];
    }
    return shared;
}


-(id)databaseEntryForKey:(NSString*)key forDataType:(id)dataType{
    KBDatabaseObject *dbObject = [self.databaseObjects objectForKey:[dataType class]];
    id result = [dbObject.objects objectForKey:key];
    return (result);
}

-(void)databaseAddEntry:(id)entry forKey:(NSString*)key{
    KBDatabaseObject *dbObject = [self.databaseObjects objectForKey:[entry class]];
    [dbObject.objects setObject:entry forKey:key];
}

-(void)enumerateDatabaseKeysForDataType:(id)dataType withBlock:(void (^)(id key))block{
    KBDatabaseObject *dbObject = [self.databaseObjects objectForKey:[dataType class]];
    [dbObject.objects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (block) {
            block(key);
        }
    }];
}

// convience functions
-(id)kibbleTypeElseLazyInitForKey:(Class)thisKibbleType{
    NSString *key = [NSString stringWithFormat:@"%@",[thisKibbleType class]];
    id item = [self kibbleForKey:key];
    if (item == nil) {
        // lazy init the element
        item = [[thisKibbleType alloc] initWithName:key parent:nil description:key];
        [[KBDatabase aDatabase] databaseAddEntry:item forKey:key];
    }
    return item;
/*
    KibbleType *item = [self kibbleForKey:key];
    if (item == nil && key) {
        // lazy init the element
        item = [[KibbleType alloc] initWithName:key parent:nil description:key];
        [[KBDatabase aDatabase] databaseAddEntry:item forKey:key];
    }
    return item;
 */
}
-(KibbleType*)kibbleForKey:(NSString*)key{
    id item = [self databaseEntryForKey:key forDataType:[KibbleType class]];
    return item;
}


@end
