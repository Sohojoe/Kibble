//
//  KEPickFromList.h
//  Kibble
//
//  Created by Joe on 4/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KETileSystem;
@interface KEPickFromSet : NSObject

/**
 * create a new pickFromSet interface
 * it does NOT draw the set until you call redrawTiles
 * @param aSetOfObjects set of objects to be added, can be nil if you want to add objects later.
 * @param aTileSystem the tile system we are using
 * @param aSuccessBlock block that will be called when the picker has finished
 * @return instancetype an instance of KETileSystem
 */
+(instancetype)pickFromSet:(NSOrderedSet*)aTileSystem using:(KETileSystem*)aTileSystem then:(void (^)(id selectedObject))aSuccessBlock;

/**
 * adds an object or set of objects to the pickFromSet
 * @param anObject the object or the NSOrderedSet of objects to be added
 */
-(void)addObjectToSet:(id)anObject;

/**
 * draws / refreshes the tiles
 */
-(void)redrawTiles;

/**
 * dimisses all the tiles and readys the instance to be destryod
 */
-(void)dismiss;

@end
