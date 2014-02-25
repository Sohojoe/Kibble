//
//  KibbleV2.m
//  Kibble
//
//  Created by Joe on 2/19/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KibbleV2.h"

@implementation KibbleV2
@synthesize myFriends, myKibbles;

-(NSMutableArray*)myKibbles{
    if (myKibbles == nil){
        myKibbles = [[NSMutableArray alloc] init];
    }
    return myKibbles;
}
-(NSMutableArray*)myFriends{
    if (myFriends == nil){
        myFriends = [[NSMutableArray alloc] init];
    }
    return myFriends;
}

@end
