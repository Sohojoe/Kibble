//
//  KETile.h
//  Kibble
//
//  Created by Joe on 2/8/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KETile : UIButton
-(void)dismiss;
@property (nonatomic, readonly) CGPoint position;

+(KETile*)tileWithImage:(UIImage*)thisImage
                     at:(CGPoint)pos
                  after:(float)delay
          addToParentVC:(UIViewController *)thisParentVC
             dataObject:(id)thisDataObject
               maxWidth:(float)maxWidth
       blockWhenClicked:(void (^)(id dataObject, KETile* tileThatWasClicked))wasClickedBlock;

+(KETile*)tileWithString:(NSString*)thisString
                      at:(CGPoint)pos
                   after:(float)delay
           addToParentVC:(UIViewController *)thisParentVC
              dataObject:(id)thisDataObject
                maxWidth:(float)maxWidth
        blockWhenClicked:(void (^)(id dataObject, KETile* tileThatWasClicked))wasClickedBlock;

@end
