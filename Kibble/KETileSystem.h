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
@property (nonatomic) UIView* parentView;

+(KETileSystem*)defaultTileSystem;

+(KETileSystem*)tileSystemWithSquareTileSize:(float)thisTileSize parentView:(id)thisParentView;

/// create a sub layer tile system starting from the current parent position
-(KETileSystem*)sublayerTileSystem;
-(void)dismiss;


-(void)editKibble:(KibbleV2*)thisKibble;


/// create a new tile in the logical space
-(KETile*)newTile;

/// move logic space to begining of next line
-(void)newLine;
/// ... and increase indent
-(void)newLineAndIndent;
/// decrease indent
-(void)popIndent;
/// reset indent
-(void)resetIndent;
/// pushes next tile position on to stack
-(void)pushCurPosition;
/// pushes next tile position on to stack and...
-(void)pushCurPositionNewLineAndIndent;
/// pops next tile  position from the stack...
-(void)popPosition;

-(KETile*)addWhatNextTile;

// theseOptions = array of callbacks to init tiles
-(void)subLayerAround:(KETile*)thisTile withOptions:(NSArray*)theseOptions;

/// return a new header tile
-(KETile*)newHeaderTile;

@end
