//
//  KBMessageEditorVC.m
//  Kibble
//
//  Created by Joe on 3/31/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KEMessageEditorVC.h"
#import "KTInterface.h"
#import "KETileSystem.h"
#import "KEPickFromSet.h"
#import "KBEditorObject.h"

@interface KEMessageEditorVC ()
@property (nonatomic, strong) KTInterface *dataInterface;
@property (nonatomic, strong) KETileSystem *tileSystem;
@property (nonatomic, strong) void(^successBlock)(BOOL success, id newKibble);
@property (nonatomic, strong) KEPickFromSet *pickSetInterface;
@property (nonatomic, strong) KEMessageEditorVC *paramInterface;
@property (nonatomic, strong) NSMutableSet *tilesToDelete;
@end

@implementation KEMessageEditorVC

+(instancetype)messageEditorUsing:(KTInterface*)aDataInterface using:(KETileSystem*)aTileSystem then:(void (^)(BOOL success, id newKibble))aSuccessBlock{
    KEMessageEditorVC *o = [KEMessageEditorVC new];
    
    // set up class
    o.dataInterface = aDataInterface;
    o.tileSystem = [aTileSystem sublayerTileSystem];
    o.successBlock = aSuccessBlock;
    o.tilesToDelete = [NSMutableSet new];
    
    // get new layer & screen
    [o redrawTiles];
    
    return o;
}
-(void)dismiss{
    [self deleteTiles:self.tilesToDelete];
    self.tilesToDelete = nil;
    self.tileSystem = nil;
    self.successBlock = nil;
    self.dataInterface = nil;
    if (self.paramInterface) {
        [self.paramInterface dismiss];
    }
    if (self.pickSetInterface) {
        [self.pickSetInterface dismiss];
        self.paramInterface = nil;
    }
    self.pickSetInterface = nil;
    [self.tileSystem dismiss];
}
-(void)redrawTiles{
    //delete current
    [self deleteTiles:self.tilesToDelete];
    
    [self.tileSystem popPosition];
    [self.tileSystem pushCurPosition];

    
    if (self.dataInterface.curClass == nil) {
        // no class, lets figure that out
        [self editClass];
        
    } else {
        [self editMessage];
    }
}

-(void)pickFromSet:(NSOrderedSet*)aSet then:(void (^)(BOOL success, id selectedObject))aSuccessBlock{

    // dismiss interfaces
    if (self.pickSetInterface) {
        [self.pickSetInterface dismiss];
    }
    if (self.paramInterface) {
        [self.paramInterface dismiss];
    }
    
    self.pickSetInterface = [KEPickFromSet pickFromSet:aSet using:self.tileSystem then:aSuccessBlock];
}
-(void)createParam:(KTMethodParam *)aParam then:(void (^)(BOOL success, id selectedObject))aSuccessBlock{
    // dismiss interfaces
    if (self.pickSetInterface) {
        [self.pickSetInterface dismiss];
    }
    if (self.paramInterface) {
        [self.paramInterface dismiss];
    }
    
    KTInterface *dataInterface = [KTInterface interfaceForClassNamed:aParam.paramType.pointee.name];


    self.paramInterface = [KEMessageEditorVC messageEditorUsing:dataInterface using:self.tileSystem then:aSuccessBlock];
}

-(void)editClass{
    __block KETile *newTile = nil;
    
    // if no foundation, select a foundation
    if (self.dataInterface.foundation == nil) {
        
        NSMutableOrderedSet *foundationSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.dataInterface.foundations];
        // sort
        [foundationSet sortUsingComparator:(NSComparator)^(KTFoundation * obj1, KTFoundation * obj2){
            return [obj1.name localizedCaseInsensitiveCompare:obj2.name];
        }];
        
        [self pickFromSet:foundationSet then:^(BOOL success, id selectedObject) {
            // set this as the foundation
            if ([selectedObject isKindOfClass:[KTFoundation class]]) {
                 self.dataInterface.foundation = selectedObject;
                // recurse
                [self redrawTiles];
            }
            
        }];
        
    }
    
    // if no class, select a class
    else if (self.dataInterface.curClass == nil) {

        newTile = [self.tileSystem newTile];
        newTile.display = self.dataInterface.foundation.name;
        [self.tilesToDelete addObject:newTile];
        
        [self.tileSystem newLineAndIndent];

        NSMutableOrderedSet *classesSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.dataInterface.classes];
        // sort
        [classesSet sortUsingComparator:(NSComparator)^(KTClass * obj1, KTClass * obj2){
            return [obj1.name localizedCaseInsensitiveCompare:obj2.name];
        }];
        
        // add classes
        [self pickFromSet:classesSet then:^(BOOL success, id selectedObject) {
            // set this as the class
            if ([selectedObject isKindOfClass:[KTClass class]]) {
                self.dataInterface.curClass = selectedObject;
            }
            
            // recurse
            [self redrawTiles];
        }];
    }

}
-(void)editMessage{
    __block KETile *newTile = nil;

    newTile = [self.tileSystem newTile];
    newTile.display = [self prettyString:self.dataInterface.curClass.name];
    [self.tilesToDelete addObject:newTile];
    
    __block NSUInteger chunkIdx = 0;
    // add chunk & params
    [self.dataInterface enumerateChunks:^(KTMethodChunk *aChunk, NSUInteger idx) {
        // add chunk
        newTile = [self.tileSystem newTile];
        newTile.display = aChunk.name;
        [self.tilesToDelete addObject:newTile];
        chunkIdx++;
        [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
            // select this chunk
            [self.dataInterface setChunkIdx:idx with:nil];
            
            // recurse
            [self redrawTiles];
            if (self.dataInterface.chunks.count) {
                [self editChunk:idx];
            }
        }];
    } andParams:^(KTMethodParam *aParm, KTMethodChunk *aChunk, NSUInteger idx) {
        // chunk param data
        if (aChunk.requiresParam) {
            newTile = [self.tileSystem newTile];
            newTile.display = [NSString stringWithFormat:@"+\n(%@)", aChunk.param.paramType];
            [self.tilesToDelete addObject:newTile];
            
            if (self.dataInterface.messageComplete) {
                [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
                    
                    
                    [self createParam:aChunk.param then:^(BOOL success, id newKibble) {
                    }];

                }];
            }
        }
    }];
    
    // add + if message is complete and if message has more options
    if (self.dataInterface.messageComplete && self.dataInterface.messageHasMoreChunks) {
        newTile = [self.tileSystem newTile];
        newTile.display = @"+";
        [self.tilesToDelete addObject:newTile];
        [newTile blockWhenClicked:^(id obj, KETile *tileThatWasClicked) {
            [self editChunk:chunkIdx];
        }];
    }
    
    if (self.dataInterface.messageComplete == NO) {
        [self editChunk:chunkIdx];
    }
}


-(void)editChunk:(NSUInteger) idx{
    
    NSMutableOrderedSet *chunkSet = [NSMutableOrderedSet new];
    // walk the chunks
    [self.dataInterface enumerateChunksAtIndex:idx chunks:^(KTMethodChunk *aChunk) {
        [chunkSet addObject:aChunk];
        
        
    } done:^(KTMethod *aMethod) {
        [chunkSet addObject:[KBEditorObjectDone editorObject]];
    }];
    
    [self pickFromSet:chunkSet then:^(BOOL success, id selectedObject) {
        if ([selectedObject isKindOfClass:[KTMethodChunk class]]) {
            // select this chunk
            [self.dataInterface setChunkIdx:idx with:selectedObject];
        }
        
        // recurse
        [self redrawTiles];
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

-(NSString*)prettyString:(NSString*)srcString{
    int index = srcString.length;
    NSMutableString* mutableInputString = [NSMutableString stringWithString:srcString];
    
    BOOL checkForNonLowercase = YES;
    
    if (index) {
        index--;
        if ([[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[mutableInputString characterAtIndex:index]]) {
            checkForNonLowercase = NO;
        }
    }
    
    while (index>1) {
        
        // if current charicter is lower case
        // and if previous charicter is not lowercase
        BOOL isCurCollon = NO;
        if ([mutableInputString characterAtIndex:index] ==[@":" characterAtIndex:0]){
            isCurCollon = YES;
        }
        BOOL isCurCharicterLowerCase = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[mutableInputString characterAtIndex:index]];
        BOOL isCurCharicterUpperCase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[mutableInputString characterAtIndex:index]];
        BOOL isPreviousCharicterLowerCase = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[mutableInputString characterAtIndex:index-1]];
        BOOL isPreviousCharicterUpperCase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[mutableInputString characterAtIndex:index-1]];
        
        if (isCurCollon) {
            [mutableInputString insertString:@" " atIndex:index+1];
        } else {
            if (isCurCharicterUpperCase && isPreviousCharicterLowerCase) {
                [mutableInputString insertString:@" " atIndex:index];
            }
            
            if (isCurCharicterLowerCase && (isPreviousCharicterUpperCase)) {
                [mutableInputString insertString:@" " atIndex:index-1];
            }
        }
        index--;
        
    }
    
    return [NSString stringWithString:mutableInputString];
    
    
}




@end
