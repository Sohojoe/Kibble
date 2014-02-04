//
//  KBEditorKibbleViewContoller.h
//  Kibble
//
//  Created by Joe on 2/3/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kibble.h"

@interface KBEditorKibbleViewContoller : UIButton
-(void)dismiss;
@property (nonatomic, readonly) CGPoint position;
@property (nonatomic, strong) KibbleType *kibbleType; // aka class, aka datemodel in MVC

-(KBEditorKibbleViewContoller*)initForThisKibble:(Kibble *)thisKibble
                                              at:(CGPoint)pos
                                           after:(float)delay
                                   addToParentVC:(UIViewController *)thisParentVC
                                        maxWidth:(float)maxWidth
                                blockWhenClicked:(void (^)(Kibble *))wasClickedBlock;

@end
