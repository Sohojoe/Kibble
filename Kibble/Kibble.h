//
//  Kibble.h
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KibbleType.h"

@interface Kibble : UIButton
-(void)dismiss;
@property (nonatomic, readonly) CGPoint position;
@property (nonatomic, strong) KibbleType *kibbleType; // aka class, aka datemodel in MVC

-(Kibble*)init:(KibbleType*)thisKibbleType
            at:(CGPoint)pos
         after:(float)delay
 addToParentVC:(UIViewController*)thisParentVC
      maxWidth:(float)maxWidth
blockWhenClicked:(void (^)(Kibble* thisKibble))wasClickedBlock;

@end
