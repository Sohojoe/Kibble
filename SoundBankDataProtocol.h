//
//  SoundBankDataProtocol.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 12/4/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SoundBankDataProtocol <NSObject>
-(NSString*)name;
@optional
-(NSString*)textToSpeach;
@end
