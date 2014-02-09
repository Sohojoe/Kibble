//
//  KETile.h
//  Kibble
//
//  Created by Joe on 2/8/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KETileSystem;

@interface KETile : UIButton
-(void)dismiss;
@property (nonatomic) CGPoint position;
@property (nonatomic, strong) id dataObject; // pass through object
@property (nonatomic, strong) id display;   // content to display support UIImage, NSString, id as str
@property (nonatomic, strong) KETileSystem *parentTileSystem;

-(void)blockWhenClicked:(void (^)(id dataObject, KETile* tileThatWasClicked))wasClickedBlock;
-(void)setDisplayWithImage:(UIImage*)thisImage;
-(void)setDisplayWithString:(NSString*)thisString;

// animations
-(void)addPopAnimation;
-(void)addAppearAnimation:(float)delay;
@end
