//
//  KBMessageEditorVC.h
//  Kibble
//
//  Created by Joe on 3/31/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KTInterface, KETileSystem;
@interface KEMessageEditorVC : NSObject

+(instancetype)messageEditorUsing:(KTInterface*)aDataInterface using:(KETileSystem*)aTileSystem then:(void (^)(BOOL success, id newKibble))aSuccessBlock;
-(void)dismiss;
@end
