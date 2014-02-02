//
//  SoundBank.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 12/4/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import "SoundBank.h"
#import "SoundBankDataProtocol.h"
#import "Parse.framework/Headers/Parse.h"
#import "Install.h"
#import "SCDatabase.h"
#import "Local.h"

@interface DatabaseObject:NSObject <SoundBankDataProtocol>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) id introductionVoice;
@property (nonatomic, strong) id  promptVoice;
@end

@interface SoundBankElement : NSObject <NSCopying>
// v3 design
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uniqueName;
@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSString *textToSpeach;
@property (nonatomic, strong) AudioElement* audioElement;
@property (nonatomic) unsigned int variationCount;
@property (nonatomic, strong) NSMutableArray *usedInTheseTests;
//v1 design
//@property (nonatomic, strong) NSString *className;
@end


@implementation SoundBankElement
- (id)copyWithZone:(NSZone *)zone
{
    SoundBankElement *copy = [[self class] allocWithZone: zone];
    
    if (copy) {
        copy.uniqueName = self.uniqueName;
        copy.name = self.name;
        copy.textToSpeach = self.textToSpeach;
        copy.object = self.object;
        copy.audioElement = self.audioElement;
    }
    return copy;
}@end


@interface SoundBank ()
@property (nonatomic, strong)NSMutableDictionary* soundbankElements;
@end

@implementation SoundBank
@synthesize soundbankElements, isLocked, localizedName;

static SoundBank* staticSoundBank;
static SoundBank* staticRegionalSoundBank;
static NSMutableArray *staticRegionalSoundBankArray;
static NSDictionary *staticRegionalSoundBankTable;

+(SoundBank*)defaultSoundBank{
    NSString *defaultSoundBankName = [[Install sharedInstall] getForKey:@"defaultSoundBankName"];
    if (defaultSoundBankName == nil) {
        //defaultSoundBankName = @"jackson";
        defaultSoundBankName = @"en-US";
    }
    
    SoundBank* defaultSoundBank = defaultSoundBank = [[SCDatabase activeDatabase] soundbankForKey:defaultSoundBankName];
    return defaultSoundBank;
}
+(void)setDefaultSoundBank:(SoundBank *)thisSoundBank{
    [[Install sharedInstall] store:thisSoundBank.name forKey:@"defaultSoundBankName"];
}
+(SoundBank*)activeSoundBank{
    return staticSoundBank;
}
+(void)setActiveSoundBank:(SoundBank*)soundBank{
    staticSoundBank = soundBank;
    [soundBank updateSndbnkElements];
}
+(void)setActiveRegionalSoundBank:(SoundBank*)soundBank{
    staticRegionalSoundBank = soundBank;
    staticRegionalSoundBankArray = [[NSMutableArray alloc]init];
    staticRegionalSoundBankTable = nil;
    
    
    if (soundBank.multipleSoundBank) {
        // it's a multipleSoundBank
        [SoundBank setActiveSoundBank:nil];
        staticRegionalSoundBankTable = soundBank.multipleSoundBank;
        NSArray *allSoundbankNames = [soundBank.multipleSoundBank allValues];
        [[SCDatabase activeDatabase]enumerateDatabaseKeysForDataType:[SoundBank class] withBlock:^(id key) {
            SoundBank *thisSoundbank = [[SCDatabase activeDatabase]soundbankForKey:key];
            if ([allSoundbankNames containsObject:thisSoundbank.name]){
                [staticRegionalSoundBankArray addObject:thisSoundbank];
                [thisSoundbank updateSndbnkElements];
            }
        }];
    } else {
        // it's a single sound bank
        [staticRegionalSoundBankArray addObject:soundBank];
        [SoundBank setActiveSoundBank:soundBank];
    }
    
}
+(SoundBank*)activeRegionalSoundBank{
    return staticRegionalSoundBank;
}
+(BOOL)isActiveRegionalSoundBankASingleSoundBank{
    BOOL answer = NO;
    if (staticRegionalSoundBankTable) {
        answer = NO;
    } else {
        answer = YES;
    }
    return answer;
}

+(void)enumerateRegionalSoundBank:(void (^)(SoundBank *soundBank))block{
    [staticRegionalSoundBankArray enumerateObjectsUsingBlock:^(SoundBank* thisSoundBank, NSUInteger idx, BOOL *stop) {
        if (block) block(thisSoundBank);
    }];
}
+(void)switchRegionalSoundBankForThisClass:(id)thisClass{
    
    SoundBank *thisSoundbank = staticRegionalSoundBank;
    
    NSString * key = [NSString stringWithFormat:@"%@", [thisClass class]];
    
    if (staticRegionalSoundBankTable) {
        // we have a true regional SoundBank
        if ([staticRegionalSoundBankTable objectForKey:key]) {
            // use override
            thisSoundbank = [[SCDatabase activeDatabase]soundbankForKey:[staticRegionalSoundBankTable objectForKey:key]];
        } else {
            // use default
            thisSoundbank = [[SCDatabase activeDatabase]soundbankForKey:[staticRegionalSoundBankTable objectForKey:@"default"]];
        }
    } else {
        // we just have a single soundbank
    }
    [SoundBank setActiveSoundBank:thisSoundbank];
}

-(NSString*)localizedName{
    NSString *key = [NSString stringWithFormat:@"SOUNDBANK_%@", self.name];
    NSString *locName = LocalStringFallback(key, [self.name capitalizedString]);
    return locName;
}


-(NSMutableDictionary*)soundbankElements{
    if (soundbankElements == nil) {
        soundbankElements = [[NSMutableDictionary alloc]init];
    }
    return soundbankElements;
}
-(BOOL)isLocked{
    if (
        [self.name caseInsensitiveCompare:@"Siri"] == NSOrderedSame
        ||[self.name caseInsensitiveCompare:@"Joe"] == NSOrderedSame
        ||[self.name caseInsensitiveCompare:@"Jackson"] == NSOrderedSame
        ){
        return YES;
    } else {
        return NO;
    }
}



//-------------------------------------------------------------------------------
// v3 interface implementation




//----------------------------------------------------
// private methods
-(SoundBankElement*)soundBankElementFor:(id)thisObject{
    if ([thisObject conformsToProtocol:@protocol(SoundBankDataProtocol)]){
        NSString *key = [SoundBank objectName:thisObject];
        SoundBankElement *soundbankElement = [self.soundbankElements objectForKey:key];
        return soundbankElement;
    } else {
        return nil;
    }
}

+(NSString*)objectName:(id)thisObject{
    NSString *result = nil;

    NSString *end = @"";
    if ([[thisObject class] conformsToProtocol:@protocol(SoundBankDataProtocol)]) {
        DatabaseObject *nameObj = thisObject;
        
        NSString *objectName = [NSString stringWithFormat:@"%@", [thisObject class]];
        NSString *instanceName = nameObj.name;


        result = [NSString stringWithFormat:@"%@%@%@",
                  objectName,
                  [instanceName capitalizedString],
                  end];
        
    }
    return result;
}



//-----------------------------------------------------------------------
// builds a list of sounds that the app will use
static NSMutableDictionary *registeredObjects = nil;
+(void)ensureRegisteredObjectsIsValid{
    if (registeredObjects == nil) {
        registeredObjects = [[NSMutableDictionary alloc]init];
    }
}

+(void)registerObject:(id)thisObject forThisTest:(SCTest*)thisTest{
    [self ensureRegisteredObjectsIsValid];
    
    NSString *key = [SoundBank objectName:thisObject];
    
    if ([registeredObjects objectForKey:key]) {
        // object exists, add thisTest
        SoundBankElement *element = [registeredObjects objectForKey:key];
        if (thisTest) {
            [element.usedInTheseTests addObject:thisTest];
        }
        
    } else {
        DatabaseObject *dbObj = thisObject;
        SoundBankElement *element = [[SoundBankElement alloc]init];
        element.uniqueName = key;
        element.object = thisObject;
        element.name = dbObj.name;
        if ([thisObject respondsToSelector:@selector(textToSpeach)]) {
            element.textToSpeach = dbObj.textToSpeach;
        }
        element.usedInTheseTests = [[NSMutableArray alloc]init];
        if (thisTest) {
            [element.usedInTheseTests addObject:thisTest];
        }
        
        [registeredObjects setObject:element forKey:key];
    }

}
+(void)flushRegisterdSounds{
    registeredObjects = nil;
}
+(void)enumerateRegisteredListWithBlock:(void (^)(id key, NSMutableArray *usedInTheseTests))block{
    [registeredObjects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        SoundBankElement *sndBankElement = obj;
        if (block) {
            block(key, sndBankElement.usedInTheseTests);
        }
    }];
}
//---------------------------------------------------
// instance code
/* old code
- (SoundBank*)initWithName:(NSString *)thisName {
    self = [super init];
    if (self) {
        // Initialize self.
        self.name = thisName;
        [self updateSndbnkElements];
    }
    return self;
}
*/
-(void)updateSndbnkElements{
    [registeredObjects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        SoundBankElement *registeredElement = obj;
        
        SoundBankElement * soundElement = [registeredElement copy];
        soundElement.audioElement = [[AudioElement alloc]initWithPath:self.name
                                                             fileName:soundElement.uniqueName
                                                         textToSpeach:soundElement.textToSpeach];
        [self.soundbankElements setObject:soundElement forKey:soundElement.uniqueName];
    }];
}
-(id)registeredObjectForKey:(id)key{
    id object;
    SoundBankElement * sndBnkObject = [self.soundbankElements objectForKey:key];
    object = sndBnkObject.object;
    return object;
}
//-----------------------------------------------------------------------
//
-(AudioElement*)audioElementFor:(id)thisObject{
    SoundBankElement *soundbankElement = [self soundBankElementFor:thisObject];
    return (soundbankElement.audioElement);
}
-(NSString *)nameFor:(id)thisObject{
    SoundBankElement *soundbankElement = [self soundBankElementFor:thisObject];
    return (soundbankElement.name);
}
-(NSString *)uniqueNameFor:(id)thisObject{
    SoundBankElement *soundbankElement = [self soundBankElementFor:thisObject];
    return (soundbankElement.uniqueName);
}
-(NSString *)textToSpeachFor:(id)thisObject{
    SoundBankElement *soundbankElement = [self soundBankElementFor:thisObject];
    return (soundbankElement.textToSpeach);
}


//-----------------------------------------------------------------------
//sync with server
-(BOOL)shouldSyncWithServer{
    // early exit if not online
    return NO;
}
-(void)syncWithServer:(void (^)(int totalActions))completionBlock progressBlock:(void (^)(NSString* update))progressBlock{
    
    // early exit if not online
    
    // request server data
    PFQuery *query = [PFQuery queryWithClassName:@"soundbanks"];
    [query whereKey:@"name" equalTo:self.name];
    __block int uploadCounter = 0;
    __block int downloadCounter = 0;
    __block int totalActions = 0;
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *serverSoundbank, NSError *error) {
        if (error) {
            // error
            if (completionBlock) completionBlock(totalActions);
        } else if (serverSoundbank == nil) {
            // no object
            if (completionBlock) completionBlock(totalActions);
        } else {
            // walk through our list
            [self.soundbankElements enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

                SoundBankElement * soundbankElement = obj;
                AudioElement * audioElement = soundbankElement.audioElement;
                
                BOOL shouldDownload = NO;
                BOOL shouldUpload = NO;
                BOOL serverDoesExist = serverSoundbank[soundbankElement.uniqueName] ? YES : NO;
                BOOL localDoesExist = audioElement.doesExist;
                PFFile *serverFile = nil;
                NSString* dateName = [NSString stringWithFormat:@"%@Date", soundbankElement.uniqueName];
                
                if (serverDoesExist && !localDoesExist) {
                    shouldDownload = YES;
                } else if (!serverDoesExist && localDoesExist) {
                    shouldUpload = YES;
                } else if (serverDoesExist && localDoesExist){
                    NSDate *localDate = audioElement.fileDate;
                    serverFile = serverSoundbank[soundbankElement.uniqueName];
                    NSDate *serverDate = serverSoundbank[dateName];
                    if ([localDate compare:serverDate] == NSOrderedAscending) {
                        // server is newer
                        shouldDownload = YES;
                    } else if ([localDate compare:serverDate] == NSOrderedDescending) {
                        // local is newer
                        shouldUpload = YES;
                    }
                }

                // force upload
                //if (localDoesExist) shouldUpload = YES;
             
                
                if (shouldUpload) {
                    // if local is newer, upload
                    totalActions++;
                    uploadCounter++;
                    NSData *data = [NSData dataWithContentsOfFile:audioElement.actualPathAndFile];
                    PFFile *file = [PFFile fileWithName:audioElement.actualFileName data:data];
                    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        uploadCounter--;
                        if (!error) {
                            serverSoundbank[soundbankElement.uniqueName] = file;
                            // save the date in a new field
                            if (audioElement.fileDate) {
                                serverSoundbank[dateName] = audioElement.fileDate;
                            } else {
                                NSLog(@"SoundBank.m:shouldSyncWithServer:shouldUpload ERROR, file %@ does not have a valid date", audioElement.actualFileName);
                            }
                            if (progressBlock) progressBlock([NSString stringWithFormat:@"%@ successfully uploaded. %d uploads to go", audioElement.actualFileName, uploadCounter]);
                        }
                        if (uploadCounter==0 && downloadCounter==0) {
                            // done
                            if (completionBlock) completionBlock(totalActions);
                            [serverSoundbank saveInBackground];
                        }
                    }];
                    
                } else if (shouldDownload) {
                    // if server is newer, download
                    totalActions++;
                    downloadCounter++;
                    PFFile *downloadFile = serverSoundbank[soundbankElement.uniqueName];
                    [downloadFile getDataInBackgroundWithBlock:^(NSData *downloadFileData, NSError *error) {
                        downloadCounter--;
                        if (!error && downloadFileData) {
                            // file was downloaded, create directory and save it
                            BOOL isDir;
                            if (! [[NSFileManager defaultManager]fileExistsAtPath:audioElement.actualPath isDirectory:&isDir]) {
                                [[NSFileManager defaultManager]createDirectoryAtPath:audioElement.actualPath withIntermediateDirectories:YES attributes:nil error:&error];
                            }
                            if ([downloadFileData writeToFile:audioElement.actualPathAndFile atomically:YES]) {
                                // ensure correct created date
                                NSMutableDictionary *fileAttr = [[NSMutableDictionary alloc] initWithDictionary:[[NSFileManager defaultManager] attributesOfItemAtPath:audioElement.actualPathAndFile error:&error]];
                                fileAttr[NSFileModificationDate] = serverSoundbank[dateName];
                                [[NSFileManager defaultManager] setAttributes:fileAttr ofItemAtPath:audioElement.actualPathAndFile error:&error];
                                
                                if (progressBlock) progressBlock([NSString stringWithFormat:@"%@ successfully downloaded. %d downloads to go", audioElement.actualFileName, downloadCounter]);
                            } else {
                                // error
                                NSLog(@"SoundBank.m:shouldSyncWithServer ERROR, file %@ failed to SAVE", audioElement.actualFileName);
                            }
                        }
                        if (uploadCounter==0 && downloadCounter==0) {
                            // done
                            if (completionBlock) completionBlock(totalActions);
                        }
                        
                    }];
                }
            }];
            if (uploadCounter==0 && downloadCounter==0) {
                // done
                if (completionBlock) completionBlock(totalActions);
            } else {
                if (progressBlock) progressBlock([NSString stringWithFormat:@"PLEASE WAIT - %d file(s) uploading. %d file(s) downloading.", uploadCounter, downloadCounter]);
            }
        }
    }];
}

@end

