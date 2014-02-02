//
//  SCElement.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/2/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCDatabaseObjectProtocol.h"

@interface SCElement : NSObject <SCDatabaseObjectProtocol>
@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSString *textToSpeach;
@property (strong, nonatomic)id image;

-(SCElement*)initWithName:(NSString*)thisName
              textToSpeach:(id)thisTextToSpeach
                    image:(id)thisImage;
@end
