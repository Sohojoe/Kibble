//
//  KBNumber.m
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KBNumber.h"

@implementation KBNumberType
-(Class)kibbleInstanceClass{return ([KBNumber class]);}
-(KBNumber*)createNewKibbleInstanceWithNumber:(NSNumber*)thisNumber{
    KBNumber *newInstance = (KBNumber*)[super createNewKibbleInstance];
    newInstance.number = thisNumber;
    newInstance.description = [NSString stringWithFormat:@"%@", thisNumber];
    return newInstance;
}
@end

//-------------------------------------------------------
@interface KBNumber ()
@end

@implementation KBNumber


@end
