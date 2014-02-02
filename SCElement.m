//
//  SCElement.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/2/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import "SCElement.h"

@implementation SCElement

-(SCElement*)initWithName:(NSString*)thisName
             textToSpeach:(id)thisTextToSpeach
                    image:(id)thisImage{
    
    
    self.name = thisName;
    self.textToSpeach = thisTextToSpeach;
    self.image = thisImage;
    
    
    // report any errors
    //if (self.name == nil) NSLog(@"SCElement:initWithName no name");
    //if (self.introductionVoice == nil) NSLog(@"SCElement:initWithName:%@ no introductionVoice",self.name);
    //if (self.image == nil) NSLog(@"SCElement:initWithName:%@ no image",self.name);
    
    return self;
}

@end
