//
//  KBMessageEditorVC.h
//  Kibble
//
//  Created by Joe on 3/31/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KTInterface, KETileSystem;
@class KTMessage;
@interface KEMessageEditorVC : NSObject

+(instancetype)messageEditorUsing:(KTInterface*)aDataInterface using:(KETileSystem*)aTileSystem then:(void (^)(KTMessage *newMessage))aSuccessBlock;
-(void)dismiss;
@end
