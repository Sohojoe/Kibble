//
//  SCDatabase.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/13/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "SCBattery.h"
#import "SCTest.h"
#import "SCPage.h"
#import "SCElement.h"
#import "SoundBank.h"

@interface SCDatabase : NSObject
+(SCDatabase *)activeDatabase;
//@property (nonatomic, strong) NSMutableDictionary *elements;
//@property (nonatomic, strong) NSMutableDictionary *pages;
//@property (nonatomic, strong) NSMutableDictionary *tests;
//@property (nonatomic, strong) NSMutableDictionary *batteries;
//@property (nonatomic, strong) NSMutableDictionary *soundbanks;

-(id)databaseEntryForKey:(NSString*)key forDataType:(id)dataType;
-(void)databaseAddEntry:(id)entry forKey:(NSString*)key;
-(void)enumerateDatabaseKeysForDataType:(id)dataType withBlock:(void (^)(id key))block;


-(void)initDatabaseWithProgressBlock:(void (^)(NSString* update))progressBlock completionBlock:(void (^)(BOOL success))completionBlock;


// helper functions
-(BOOL)hasDatabaseCompletedLoading:(void (^)(NSString *info))stillLoadingBlock;

// convience functions
-(SCElement*)elementElseLazyInitForKey:(NSString*)key;
-(SCElement*)elementForKey:(NSString*)key;
-(SCPage*)pageForKey:(NSString*)key;
-(SCTest*)testForKey:(NSString*)key;
-(SCBattery*)batteryForKey:(NSString*)key;
-(SoundBank*)soundbankForKey:(NSString*)key;


@end
