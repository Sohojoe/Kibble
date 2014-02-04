//
//  KBNumber.h
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "Kibble.h"
@class KBNumber;
@interface KBNumberType : KibbleType
-(KBNumber*)createNewKibbleInstanceWithNumber:(NSNumber*)thisNumber;
@end

@interface KBNumber : Kibble
@property (nonatomic,strong) NSNumber *number;
@end

