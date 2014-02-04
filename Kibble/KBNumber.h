//
//  KBNumber.h
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "Kibble.h"

@interface KBNumberType : KibbleType
+(void)debugPrintTypes;
@end

@interface KBNumber : Kibble
-(Kibble*)initWithNumber:(NSNumber*)thisNumber
                      at:(CGPoint)pos
                   after:(float)delay
           addToParentVC:(UIViewController*)thisParentVC
                maxWidth:(float)maxWidth
        blockWhenClicked:(void (^)(Kibble* thisKibble))wasClickedBlock;
@end

