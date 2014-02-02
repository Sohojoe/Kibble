//
//  SoundBank.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 12/4/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AudioWrapper.h"



#import "SoundBankDataProtocol.h"
@interface SoundBank : NSObject <SoundBankDataProtocol>
@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSDictionary *multipleSoundBank;
//-(SoundBank*)initWithName:(NSString*) thisName;


// regionalSoundBanks allow for multiple sounds banks within a region
// for example, in the US, we have Jackson as the default, and Karina as the override for certain tests
// the functions internal recoganise regoinal the difference between regional and actual sound banks
// ---mutipleSoundBank = a soundbank that internally referances multiple sound banks. This allows for a region to have multiple voices for different tests. A mutitple sound bank does not have any actual samples
// ---singleSoundBank = the traditional sound bank that has samples
// the regionalSoundBank can be set to eith a single or multiple. Use isActiveRegionalSoundBankASingleSoundBank to determin what it is set to

+(SoundBank*)activeSoundBank;
+(void)setActiveRegionalSoundBank:(SoundBank*)soundBank;
+(SoundBank*)activeRegionalSoundBank;
+(BOOL)isActiveRegionalSoundBankASingleSoundBank;
+(void)enumerateRegionalSoundBank:(void (^)(SoundBank *soundBank))block;
+(void)switchRegionalSoundBankForThisClass:(id)thisClass;
+(SoundBank*)defaultSoundBank;
+(void)setDefaultSoundBank:(SoundBank*)thisSoundBank;

@property (nonatomic, readonly) BOOL isLocked;
@property (nonatomic, readonly, strong) NSString *localizedName;

// sync with server
-(void)syncWithServer:(void (^)(int totalActions))completionBlock progressBlock:(void (^)(NSString* update))progressBlock;

//v3 Interface
// return this objects audioElement for the default sound - randaomly chooses from variations
-(AudioElement*)audioElementFor:(id)thisObject;
// return this variation of this objects audioElement for the default sound
//-(AudioElement*)audioElementFor:(id)thisObject variation:(unsigned int)thisVariation;
// return this objects audioElement for this custom sound - randaomly chooses from variations
//-(AudioElement*)audioElementFor:(id)thisObject customSound:(NSString*)customSound;
// return this variation of this objects audioElement for this custom sound
//-(AudioElement*)audioElementFor:(id)thisObject customSound:(NSString*)customSound variation:(unsigned int)thisVariation;

// element public interface
// .. get info on thisObject's sounds on this soundBank
-(NSString *)nameFor:(id)thisObject;
-(NSString *)uniqueNameFor:(id)thisObject;
-(NSString *)textToSpeachFor:(id)thisObject;
//-(unsigned int)variationCountFor:(id)thisObject;



//+(void)registerObject:(id)thisObject;
+(void)registerObject:(id)thisObject forThisTest:(id)thisTest;
+(void)flushRegisterdSounds;
+(void)enumerateRegisteredListWithBlock:(void (^)(id key, NSMutableArray *usedInTheseTests))block;
-(id)registeredObjectForKey:(id)key;



@end
