//
//  KETileSystem.h
//  Kibble
//
//  Created by Joe on 2/8/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KETile.h"

@interface KETileSystem : NSObject

@property (nonatomic) CGFloat tileSize;               // assumes square size
@property (nonatomic) UIViewController* parentViewController;

+(KETileSystem*)defaultTileSystem;

+(KETileSystem*)tileSystemWithSquareTileSize:(float)thisTileSize parentVC:(id)thisParentViewController;

-(KETile*)newTile;                  // create a new tile in the logical space
-(KETile*)newTileOnNewLine;         // ... on the next line


@end
