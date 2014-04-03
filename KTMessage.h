//
//  KTMessage.h
//  Kibble
//
//  Created by Joe on 4/2/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KTMessage : NSObject
@property (nonatomic, strong) NSString* messageName;
@property (nonatomic, strong) NSMutableArray *params;
@property (nonatomic, weak) id recievingObject;
@property (nonatomic, copy) id returnedObject;

+(instancetype)messageWith:(NSString*)aMessageName with:(NSMutableArray*)theParams;
-(id)sendMessageTo:(id)recievingObject;
-(id)sendMessage;
@end
