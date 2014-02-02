//
//  SCDatabase.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/13/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import "SCDatabase.h"
#import "BackEnd.h"
#import "Parse.framework/Headers/Parse.h"
#import <Foundation/NSDate.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "SoundBank.h"
#import "SCDatabaseObjectProtocol.h"

@interface SCDatabaseObjectProtocolFull : NSObject
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* textToSpeach;
@property (nonatomic, strong) id image;
@property (nonatomic, strong) id promptVoice;
@property (nonatomic, strong) id prompt;
@property (nonatomic, strong) NSArray* targets;
@property (nonatomic) uint correctTarget;
@property (nonatomic) BOOL compareAnswerWithCorrectTarget;
@property (nonatomic, strong) NSArray* pages;
@property (nonatomic, strong) NSArray* tests;
@property (nonatomic, strong) NSDictionary* multipleSoundBank;
@end @implementation SCDatabaseObjectProtocolFull @end

@interface SCDatabaseObject : NSObject 
@property (nonatomic, strong) id objectType;
@property (nonatomic, strong) NSString *objectName;
@property (nonatomic, strong) NSDate *timeStamp;
@property (nonatomic, strong) NSMutableDictionary *objects;
@end @implementation SCDatabaseObject @end

@interface SCDatabase()
@property (nonatomic, strong) NSDate *elementTimeStamp, *pageTimeStamp, *testTimeStamp, *batteryTimeStamp, *soundbankTimeStamp;
@property (nonatomic) int initDatabaseCallbackCount;
@property (nonatomic, strong) NSMutableDictionary *databaseObjects;
@end

@implementation SCDatabase
@synthesize databaseObjects;


+(SCDatabase*)activeDatabase{
    static SCDatabase *shared = nil;
    
    if (shared==nil) {
        // first Time Init
        shared = [[super allocWithZone:NULL] init];
    }
    return shared;
}

-(id)databaseEntryForKey:(NSString*)key forDataType:(id)dataType{
    SCDatabaseObject *dbObject = [self.databaseObjects objectForKey:[dataType class]];
    id result = [dbObject.objects objectForKey:key];
    return (result);
}

-(void)databaseAddEntry:(id)entry forKey:(NSString*)key{
    SCDatabaseObject *dbObject = [self.databaseObjects objectForKey:[entry class]];
    [dbObject.objects setObject:entry forKey:key];
}

-(void)enumerateDatabaseKeysForDataType:(id)dataType withBlock:(void (^)(id key))block{
    SCDatabaseObject *dbObject = [self.databaseObjects objectForKey:[dataType class]];
    [dbObject.objects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (block) {
            block(key);
        }
    }];
}

//--------------------------------------------------------------------------------
-(SCElement*)elementElseLazyInitForKey:(NSString*)key{
    SCElement *item = [self elementForKey:key];
    if (item == nil && key) {
        // lazy init the element
        item = [[SCElement alloc] initWithName:key textToSpeach:key image:nil];
        [[SCDatabase activeDatabase] databaseAddEntry:item forKey:key];
    }
    return item;
}

// Helper functions
-(SCElement*)elementForKey:(NSString*)key{
    id item = [self databaseEntryForKey:key forDataType:[SCElement class]];
    return item;
}
-(SCPage*)pageForKey:(NSString*)key{
    id item = [self databaseEntryForKey:key forDataType:[SCPage class]];
    return item;
}
-(SCTest*)testForKey:(NSString*)key{
    id item = [self databaseEntryForKey:key forDataType:[SCTest class]];
    return item;
}
-(SCBattery*)batteryForKey:(NSString*)key{
    id item = [self databaseEntryForKey:key forDataType:[SCBattery class]];
    return item;
}
-(SoundBank*)soundbankForKey:(NSString *)key{
    id item = [self databaseEntryForKey:key forDataType:[SoundBank class]];
    return item;
}
//--------------------------------------------------------------------------------
-(BOOL)hasDatabaseCompletedLoading:(void (^)(NSString *info))stillLoadingBlock{
    if (self.initDatabaseCallbackCount ==0) {
        return YES;
    } else {
        if (stillLoadingBlock) {
            stillLoadingBlock([NSString stringWithFormat:@"currently waiting for %d items.", self.initDatabaseCallbackCount]);
        }
        return NO;
    }
}

//--------------------------------------------------------------------------------
//
-(void)initDatabaseWithProgressBlock:(void (^)(NSString* update))progressBlock completionBlock:(void (^)(BOOL success))completionBlock{
    self.initDatabaseCallbackCount = 0;
    
    //uncomment to always clear all cached results
    //[PFQuery clearAllCachedResults];

    [self syncDatabaseObject:[SCElement class] progressBlock:progressBlock completionBlock:^(BOOL success) {
        [self syncDatabaseObject:[SCPage class] progressBlock:progressBlock completionBlock:^(BOOL success) {
            [self syncDatabaseObject:[SCTest class] progressBlock:progressBlock completionBlock:^(BOOL success) {
                [self syncDatabaseObject:[SCBattery class] progressBlock:progressBlock completionBlock:^(BOOL success) {
                    [self syncDatabaseObject:[SoundBank class] progressBlock:progressBlock completionBlock:^(BOOL success) {
                        if (completionBlock) completionBlock(YES);
                    }];
                    
                }];
                
            }];
            
        }];
        
    }];
}

// lazy init databaseObjects
-(NSMutableDictionary*)databaseObjects{
    if (databaseObjects == nil) {
        databaseObjects = [[NSMutableDictionary alloc]init];
        
        // lazy init all our supported types
        [self lazyAddDatabaseObject:[SCElement class] objectName:@"elements"];
        [self lazyAddDatabaseObject:[SCPage class] objectName:@"pages"];
        [self lazyAddDatabaseObject:[SCTest class] objectName:@"tests"];
        [self lazyAddDatabaseObject:[SCBattery class] objectName:@"batteries"];
        [self lazyAddDatabaseObject:[SoundBank class] objectName:@"soundbanks"];
    }
    return databaseObjects;
}

-(void)lazyAddDatabaseObject:(id)objectType
                  objectName:(NSString*)objectName{
    
    // check if we can load from installInstance
    
    // otherwise create
    SCDatabaseObject *newDBObj = [[SCDatabaseObject alloc]init];
    newDBObj.objectType = objectType;
    newDBObj.objectName = objectName;
    newDBObj.objects = [[NSMutableDictionary alloc]init];
    [self.databaseObjects setObject:newDBObj forKey:objectType];
    
}


-(void)syncDatabaseObject:(id)objectType progressBlock:(void (^)(NSString* update))progressBlock completionBlock:(void (^)(BOOL success))completionBlock{
    // pull from server
    
    //kPFCachePolicyNetworkElseCache
    //kPFCachePolicyCacheOnly
    [self syncDatabaseObject:objectType withParseCachePolicy:kPFCachePolicyCacheOnly progressBlock:^(NSString *update) {
        //if(update) if (progressBlock) progressBlock([NSString stringWithFormat:@"%@ - LOCAL",update]);
    } completionBlock:^(BOOL success) {
        if ([[BackEnd sharedBackEnd] isInternetConnectionValid]){
            // pull from network
            //[self syncDatabaseObject:objectType withParseCachePolicy:kPFCachePolicyNetworkOnly progressBlock:^(NSString *update) {
            [self syncDatabaseObject:objectType withParseCachePolicy:kPFCachePolicyNetworkElseCache progressBlock:^(NSString *update) {
                //if(update) if (progressBlock) progressBlock([NSString stringWithFormat:@"%@ - CLOUD",update]);
                if(update) if (progressBlock) progressBlock(update);
            } completionBlock:^(BOOL success) {
                if (completionBlock) completionBlock(success);
            }];
        } else {
            // no internet, just end with what we have
            if (completionBlock) completionBlock(success);
        }
    }];
    

}

-(void)syncDatabaseObject:(id)objectType withParseCachePolicy:(PFCachePolicy)cachePolicy progressBlock:(void (^)(NSString* update))progressBlock completionBlock:(void (^)(BOOL success))completionBlock{

    SCDatabaseObject *thisObject = self.databaseObjects[objectType];
    if (thisObject == nil) {
        NSString *progress = [NSString stringWithFormat:@"SCDatabase:syncDatabaseObject Error, object '%@' does not exist", objectType];
        if (progressBlock) progressBlock(progress);
        NSLog(@"%@",progress);
        if (completionBlock) completionBlock(NO);
        return;
    }
    
    if ([thisObject.objectType conformsToProtocol:@protocol(SCDatabaseObjectProtocol)]
        || [thisObject.objectType conformsToProtocol:@protocol(SoundBankDataProtocol)]) {
        
        PFQuery *elementsQuery = [PFQuery queryWithClassName:thisObject.objectName];
        elementsQuery.cachePolicy = cachePolicy;
        elementsQuery.limit = 1000;
        if (thisObject.timeStamp) {
            [elementsQuery whereKey:@"updatedAt" greaterThan:thisObject.timeStamp];
        }
        
        self.initDatabaseCallbackCount++;
        [elementsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.initDatabaseCallbackCount--;
            
            if (error) {
                if (error.code == kPFErrorCacheMiss) {
                    // it's ok, there is no cache
                    NSString *progress = [NSString stringWithFormat:@"%d %@ objects found", (int)objects.count, thisObject.objectType];
                    if (progressBlock) progressBlock(progress);
                    NSLog(@"%@",progress);
                    if (completionBlock) completionBlock(YES);
                } else {
                    // unsupported error
                    NSString *progress = [NSString stringWithFormat:@"SCDatabase:syncDatabaseObject %@ Error %@", thisObject.objectType, error];
                    if (progressBlock) progressBlock(progress);
                    NSLog(@"%@",progress);
                    if (completionBlock) completionBlock(NO);
                }
            } else if (objects == 0) {
                NSString *progress = [NSString stringWithFormat:@"SCDatabase:syncDatabaseObject Error No %@ objects Found", thisObject.objectType];
                if (progressBlock) progressBlock(progress);
                NSLog(@"%@",progress);
            } else {
                // success
                [objects enumerateObjectsUsingBlock:^(PFObject *obj, NSUInteger idx, BOOL *stop) {
                    // parse each object
                    // check if this is the latest time
                    if (thisObject.timeStamp) {
                        if ([thisObject.timeStamp compare:obj.updatedAt] == NSOrderedAscending) {
                            thisObject.timeStamp = obj.updatedAt;
                        }
                    }else {
                        thisObject.timeStamp = obj.updatedAt;
                    }
                    
                    
                    
                    // create new element
                    id newObject = [[thisObject.objectType alloc]init];
                    SCDatabaseObjectProtocolFull *protocalObj = newObject;
                    
                    
                    if ([newObject respondsToSelector:@selector(name)]) {
                        protocalObj.name=obj[@"name"];
                    }
                    if ([newObject respondsToSelector:@selector(textToSpeach)]) {
                        protocalObj.textToSpeach = obj[@"introEN"];
                    }
                    if ([newObject respondsToSelector:@selector(prompt)]) {
                        if (obj[@"prompt"]) {
                            //id item = [self databaseEntryForKey:obj[@"prompt"] forDataType:[SCElement class]];
                            NSString* key = obj[@"prompt"];
                            id item = [self elementElseLazyInitForKey:key];
                            protocalObj.prompt = item;
                        }
                    }
                    if ([newObject respondsToSelector:@selector(multipleSoundBank)]) {
                        NSMutableArray *sourceArray = [[NSMutableArray alloc] initWithArray:obj[@"multipleSoundBank"]];
                        if (sourceArray.count>1) {
                            // it's a multipleSoundBank, conver array to a dictionary
                            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]initWithCapacity:sourceArray.count];
                            while (sourceArray.count >=2) {
                                NSString *key = [sourceArray objectAtIndex:0];
                                NSString *value = [sourceArray objectAtIndex:1];
                                [sourceArray removeObjectAtIndex:0];
                                [sourceArray removeObjectAtIndex:0];
                                [dictionary setObject:value forKey:key];
                            }
                            protocalObj.multipleSoundBank = [[NSDictionary alloc]initWithDictionary:dictionary];
                            
                        } else {
                            // it's a singleSoundBank, store nil
                            protocalObj.multipleSoundBank = nil;
                        }
                        
                    }

                    if ([newObject respondsToSelector:@selector(targets)]) {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        for (NSString* key in obj[@"targets"]) {
                            id item = [self elementElseLazyInitForKey:key];
                            if (item == nil) {
                                NSString *progress = [NSString stringWithFormat:@"initPage: ERROR item '%@' is not in database", key];
                                if (progressBlock) progressBlock(progress);
                                NSLog(@"%@",progress);
                            } else {
                                [array addObject:item];
                            }
                        }
                        protocalObj.targets = array;
                    }
                    if ([newObject respondsToSelector:@selector(correctTarget)]) {
                        if (obj[@"correctTarget"]) {
                            protocalObj.correctTarget = [obj[@"correctTarget"] unsignedIntValue];
                        }
                    }
                    if ([newObject respondsToSelector:@selector(compareAnswerWithCorrectTarget)]) {
                        if (obj[@"compareAnswerWithCorrectTarget"]) {
                            protocalObj.compareAnswerWithCorrectTarget = [obj[@"compareAnswerWithCorrectTarget"] boolValue];
                        }
                    }
                    
                    if ([newObject respondsToSelector:@selector(pages)]) {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        for (NSString* key in obj[@"pages"]) {
                            id item = [self databaseEntryForKey:key forDataType:[SCPage class]];
                            if (item == nil) {
                                NSString *progress = [NSString stringWithFormat:@"initPage: ERROR item '%@' is not in database", key];
                                if (progressBlock) progressBlock(progress);
                                NSLog(@"%@",progress);
                            } else {
                                [array addObject:item];
                            }
                        }
                        protocalObj.pages = array;
                    }
                    if ([newObject respondsToSelector:@selector(tests)]) {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        for (NSString* key in obj[@"tests"]) {
                            id item = [self databaseEntryForKey:key forDataType:[SCTest class]];
                            if (item == nil) {
                                NSString *progress = [NSString stringWithFormat:@"initPage: ERROR item '%@' is not in database", key];
                                if (progressBlock) progressBlock(progress);
                                NSLog(@"%@",progress);
                            } else {
                                [array addObject:item];
                            }
                        }
                        protocalObj.tests = array;
                    }
                    
                    if ([newObject respondsToSelector:@selector(image)]) {
                        // handle image load
                        PFFile *imageFile = obj[@"image"];
                        if (imageFile == nil) {
                            NSString *progress = [NSString stringWithFormat:@"SCDatabase:syncDatabaseObject WARNING '%@' no image in database", protocalObj.name];
                            if (progressBlock) progressBlock(progress);
                            NSLog(@"%@",progress);
                        } else {
                            self.initDatabaseCallbackCount++;
                            [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                                self.initDatabaseCallbackCount--;
                                if (!error) {
                                    protocalObj.image = [UIImage imageWithData:imageData];
                                } else {
                                    NSString *progress = [NSString stringWithFormat:@"SCDatabase:syncDatabaseObject ERROR '%@' unable to load image", protocalObj.image];
                                    if (progressBlock) progressBlock(progress);
                                    NSLog(@"%@",progress);
                                }
                            }];
                        }
                    }
                    
                    
                    // add to dictionary
                    if (protocalObj.name) {
                        [thisObject.objects setObject:newObject forKey:protocalObj.name];
                    }
                    
                    
                    
                }];
                NSString *progress = [NSString stringWithFormat:@"%d %@ objects found", (int)objects.count, thisObject.objectType];
                if (progressBlock) progressBlock(progress);
                NSLog(@"%@",progress);
                
                if (completionBlock) completionBlock(YES);
            }
            
        }];

        
    } else {
        NSString *progress = [NSString stringWithFormat:@"SCDatabase:syncDatabaseObject Error, object type '%@' is not currently supported", objectType];
        if (progressBlock) progressBlock(progress);
        NSLog(@"%@",progress);
        if (completionBlock) completionBlock(NO);
    }
    
}


@end
