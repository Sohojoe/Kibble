//
//  SoundBankControllerProtocol.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 12/6/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Soundbank.h"

@protocol SoundBankControllerProtocol <NSObject>

+(void)registerWithSoundbank:(id)thisDataset;

@end
