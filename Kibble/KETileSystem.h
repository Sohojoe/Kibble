//
//  KETileSystem.h
//  Kibble
//
//  Created by Joe on 2/8/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KETile.h"
#import "KETileLayer.h"

@class KibbleV2;
@interface KETileSystem : NSObject

@property (nonatomic) CGFloat tileSize;               // assumes square size
@property (nonatomic) UIViewController* parentViewController;

+(KETileSystem*)defaultTileSystem;

+(KETileSystem*)tileSystemWithSquareTileSize:(float)thisTileSize parentVC:(id)thisParentViewController;

-(void)editKibble:(KibbleV2*)thisKibble;

-(KETile*)newTile;                  // create a new tile in the logical space

-(void)newLine;                     // move logic space to begining of next line
-(void)newLineAndIndent;            // ... and increase indent
-(void)popIndent;                   // decrease indent
-(void)resetIndent;                 // reset indent

-(KETile*)addWhatNextTile;

// theseOptions = array of callbacks to init tiles
-(void)subLayerAround:(KETile*)thisTile withOptions:(NSArray*)theseOptions;

@end
