//
//  SCElementViewController.h
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/9/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SCTestController.h"
#import "SCElement.h"


@interface SCElementViewController : UIButton
-(SCElementViewController*)init:(SCElement*)thisElement at:(CGPoint)pos after:(float)delay  addToParentView:(UIView*)view blockWhenClicked:(void (^)(SCElementViewController* thisElement))wasClickedBlock;
-(SCElementViewController*)init:(SCElement*)element at:(CGPoint)pos after:(float)delay maxWidth:(float)maxWidth addToTest:(UIView*)view;
-(void)dismiss;
-(void)addPopAnimation;
@property (nonatomic, readonly) CGPoint position;
@property (nonatomic, strong) SCElement *element;
@end
@interface SCElementTargetViewController : SCElementViewController
@end
@interface SCElementPromptViewController : SCElementViewController
@end
@interface SCElementSpeakerViewController : SCElementViewController
@end
