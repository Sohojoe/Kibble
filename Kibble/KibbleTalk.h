//
//  KibbleTalk.h
//  Kibble
//
//  Created by Joe on 2/4/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "Kibble.h"

@interface KibbleTalk : Kibble
@property (nonatomic, strong, readonly) id result;

-(void)addKibbleTalkParamater:(id)thisParamater withSyntax:(NSString*)thisSyntax andDescription:(NSString*)thisDescription;


@end
