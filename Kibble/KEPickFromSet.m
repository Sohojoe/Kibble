//
//  KEPickFromSet.m
//  Kibble
//
//  Created by Joe on 4/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KEPickFromSet.h"
#import "KETileSystem.h"
#import "KTInterface.h"
#import "KBEditorObject.h"

@interface KEPickFromSet ()
@property (nonatomic, strong) KETileSystem *tileSystem;
@property (nonatomic, strong) void(^successBlock)(BOOL success, id selectedObject);
@property (nonatomic, strong) NSMutableSet *tilesToDelete;
@property (nonatomic, strong) NSMutableOrderedSet *objectsToPickFrom;
@end

@implementation KEPickFromSet
+(instancetype)pickFromSet:(NSOrderedSet*)aSetOfObjects using:(KETileSystem*)aTileSystem then:(void (^)(BOOL success, id selectedObject))aSuccessBlock{
    KEPickFromSet *o = [KEPickFromSet new];
    
    // set up class
    o.tileSystem = [aTileSystem sublayerTileSystem];
    o.successBlock = aSuccessBlock;
    o.tilesToDelete = [NSMutableSet new];
    o.objectsToPickFrom = [NSMutableOrderedSet new];
    [o addObjectToSet:aSetOfObjects];
    // get new layer & screen
    
    //[o.tileSystem newLineAndIndent];
    [o.tileSystem pushCurPosition];
    [o redrawTiles];
    
    return o;
}
-(void)dismiss{
    [self.tileSystem dismiss];
    [self deleteTiles:self.tilesToDelete];
    self.tilesToDelete = nil;
    self.tileSystem = nil;
    self.successBlock = nil;
}

-(void)addObjectToSet:(id)anObject{
    BOOL setHasObjects = (BOOL)self.objectsToPickFrom.count;
    
    // look at different types of objects that we support
    if ([anObject isKindOfClass:[NSOrderedSet class]]) {
        NSOrderedSet *anOrderedSet = anObject;
        if (setHasObjects == NO) {
            [anOrderedSet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self addObjectToSet:obj];
            }];
        }else {
            [self.objectsToPickFrom addObject:anOrderedSet];
        }
    }
    
    else {
        [self.objectsToPickFrom addObject:anObject];
    }
}
-(void)redrawTiles{
    [self clearThenDrawSet:self.objectsToPickFrom];
}
-(void)clearThenDrawSet:(NSOrderedSet*)setToDraw{
    //delete current
    [self deleteTiles:self.tilesToDelete];
    
    [self.tileSystem popPosition];
    [self.tileSystem pushCurPosition];
    
    [self drawSet:setToDraw];
}
-(void)drawSet:(NSOrderedSet*)setToDraw{

    __block KETile *newTile = nil;

    [setToDraw enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        // handle subsets
        if ([obj isKindOfClass:[NSOrderedSet class]]) {
            NSOrderedSet *aSet = obj;
            newTile = [self.tileSystem newTile];
            newTile.display = @"SUB\nLIST";
            [self.tilesToDelete addObject:newTile];
            
            [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {

                // draw this list
                [self clearThenDrawSet:aSet];
                
                // add back
                newTile = [self.tileSystem newTile];
                newTile.display = @"BACK";
                [self.tilesToDelete addObject:newTile];
                [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
                    [self clearThenDrawSet:setToDraw];
                }];
            }];
        }

        // handle chunks & params
        else if ([obj isKindOfClass:[KTMethodChunk class]] ||
                 [obj isKindOfClass:[KTMethodParam class]] ||
                 [obj isKindOfClass:[KTClass class]] ||
                 [obj isKindOfClass:[KTFoundation class]] ) {
            
            newTile = [self.tileSystem newTile];
            if ([obj respondsToSelector:@selector(name)]) {
                newTile.display = [obj performSelector:@selector(name)];
            }
            [self.tilesToDelete addObject:newTile];
            
            [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
                
                // we're done, we've found our object
                if (self.successBlock) {
                    self.successBlock(YES,obj);
                }
                [self dismiss];
            }];
        }
        else if ([obj isKindOfClass:[KBEditorObject class]]){
            newTile = [self.tileSystem newTile];
            if ([obj respondsToSelector:@selector(name)]) {
                newTile.display = [obj performSelector:@selector(name)];
            }
            [self.tilesToDelete addObject:newTile];
            
            [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
                // we're done
                if (self.successBlock) {
                    self.successBlock(YES,obj);
                }
                [self dismiss];
            }];
        }
        
        else {
            // un supported class
            NSLog(@"KEPickFromSet->drawSet: Class type '%@' is not supported", [obj class]);
        }
    }];
}

//---------------------------------------------------------
//
// helpers
//
-(void)deleteTiles:(NSMutableSet*)tilesToDelete{
    [tilesToDelete enumerateObjectsUsingBlock:^(KETile *aTile, BOOL *stop) {
        [aTile dismiss];
    }];
    [tilesToDelete removeAllObjects];
    
}
@end
