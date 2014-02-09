//
//  KETileSystem.m
//  Kibble
//
//  Created by Joe on 2/8/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KETileSystem.h"
#import <UIKit/UIKit.h>

@interface KETileSystem ()
@property (nonatomic) CGPoint nextTilePosition;
@property (nonatomic) CGSize tileMargin;
@end

@implementation KETileSystem

+(KETileSystem*)defaultTileSystem{
    static KETileSystem *shared = nil;
    
    if (shared==nil) {
        // first Time Init
        shared = [[super allocWithZone:NULL] init];
    }
    return shared;
}
+(KETileSystem*)tileSystemWithSquareTileSize:(float)thisTileSize parentVC:(id)thisParentViewController{
    KETileSystem *newSystem = [[KETileSystem alloc]init];
    newSystem.tileSize = thisTileSize;
    newSystem.parentViewController = thisParentViewController;
    
    [newSystem resetNextTilePositionToMiddleLeft];
    return (newSystem);
}
-(void)resetNextTilePositionToTopLeft{
    self.nextTilePosition = CGPointMake(self.tileSize /2 + (self.tileMargin.width /2), self.tileSize /2 + (self.tileMargin.height /2));
}
-(void)resetNextTilePositionToMiddleLeft{
    self.nextTilePosition
    = CGPointMake(self.tileSize /2 + (self.tileMargin.width /2),
                  self.parentViewController.view.frame.size.height /2);
}


-(id)init{
    self = [super init];
    
    // defaults
    self.tileSize = 128;
    self.tileMargin = CGSizeMake(8.0, 8.0);
    return self;
}

-(KETile*)newTile{
    CGRect frame = CGRectMake(0, 0, self.tileSize, self.tileSize);
    KETile *ourNewTile = [[KETile alloc]initWithFrame:frame];
    
    ourNewTile.position = self.nextTilePosition;
    
    CGPoint pos =self.nextTilePosition;;
    pos.x = self.nextTilePosition.x + self.tileSize + self.tileMargin.width;
    self.nextTilePosition = pos;

    ourNewTile.parentTileSystem = self;
    
    [self.parentViewController.view addSubview:ourNewTile];
    
    [ourNewTile addPopAnimation];
 
    
    return (ourNewTile);
}
-(KETile*)newTileOnNewLine{
    CGPoint pos =self.nextTilePosition;
    pos.y = self.nextTilePosition.y + self.tileSize + self.tileMargin.height;
    pos.x = self.tileSize /2 + (self.tileMargin.width /2 );
    self.nextTilePosition = pos;
    return ([self newTile]);
}
@end
