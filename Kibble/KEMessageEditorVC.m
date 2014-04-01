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


@interface KEMessageEditorVC ()
@property (nonatomic, strong) KTInterface *dataInterface;
@property (nonatomic, strong) KETileSystem *tileSystem;
@property (nonatomic, strong) void(^successBlock)(BOOL success, id newKibble);
@property (nonatomic, strong) NSMutableSet *tilesToDelete;
@end

@implementation KEMessageEditorVC

+(instancetype)messageEditorUsing:(KTInterface*)aDataInterface using:(KETileSystem*)aTileSystem then:(void (^)(BOOL success, id newKibble))aSuccessBlock{
    KEMessageEditorVC *o = [KEMessageEditorVC new];
    
    // set up class
    o.dataInterface = aDataInterface;
    o.tileSystem = aTileSystem;
    o.successBlock = aSuccessBlock;
    o.tilesToDelete = [NSMutableSet new];
    
    // get new layer & screen
    
    [o refreshTiles];
    
    return o;
}
-(void)dismiss{
    [self deleteTiles:self.tilesToDelete];
    self.tilesToDelete = nil;
    self.tileSystem = nil;
    self.successBlock = nil;
    self.dataInterface = nil;
}
-(void)refreshTiles{
    //delete current
    [self deleteTiles:self.tilesToDelete];
    
    [self.tileSystem popPosition];
    [self.tileSystem pushCurPositionNewLineAndIndent];

    
    if (self.dataInterface.curClass == nil) {
        // no class, lets figure that out
        [self editClass];
        
    } else {
        [self editMessage];
    }
}
-(void)editClass{
    __block KETile *newTile = nil;
    
    // if no foundation, select a foundation
    if (self.dataInterface.foundation == nil) {
        
        // add foundations
        [self.dataInterface.foundations enumerateObjectsUsingBlock:^(KTFoundation *thisFoundation, NSUInteger idx, BOOL *stop) {
            
            newTile = [self.tileSystem newTile];
            newTile.display = [self prettyString:thisFoundation.name];
            newTile.dataObject = thisFoundation;
            [self.tilesToDelete addObject:newTile];
            
            [self.tileSystem newLineAndIndent];
            
            [newTile blockWhenClicked:^(KTFoundation *thisFoundation, KETile *tileThatWasClicked) {
                
                // set this as the class
                self.dataInterface.foundation = thisFoundation;
                
                // recurse
                [self refreshTiles];
            }];
        }];
        
    }
    
    // if no class, select a class
    else if (self.dataInterface.curClass == nil) {

        newTile = [self.tileSystem newTile];
        newTile.display = self.dataInterface.foundation.name;
        [self.tilesToDelete addObject:newTile];
        
        [self.tileSystem newLineAndIndent];
        
        // add classes
        [self.dataInterface.classes enumerateObjectsUsingBlock:^(KTClass *aClass, NSUInteger idx, BOOL *stop) {
            
            //if ([aClass.name isEqualToString:@"NSString"] == NO) {
            //    return;
            //}
            
            newTile = [self.tileSystem newTile];
            newTile.display = [self prettyString:aClass.name];
            newTile.dataObject = aClass;
            [self.tilesToDelete addObject:newTile];
            
            [newTile blockWhenClicked:^(KTClass *aClass, KETile *tileThatWasClicked) {
                
                // set this as the class
                self.dataInterface.curClass = aClass;

                // recurse
                [self refreshTiles];
            }];
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
            [self refreshTiles];
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
                    KTInterface *dataInterface = [KTInterface interface];
                    dataInterface.initerMode = YES;
                    dataInterface.curClass = [KTClass classWithName:aChunk.param.paramType.pointee.name];
                    
                    static KEMessageEditorVC *mEdit;
                    if (mEdit) {
                        [mEdit dismiss];
                    }
                    [self.tileSystem pushCurPositionNewLineAndIndent];
                    mEdit = [KEMessageEditorVC messageEditorUsing:dataInterface using:self.tileSystem then:^(BOOL success, id newKibble) {
                        
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
    [self.tileSystem newLineAndIndent];
    
    if (self.dataInterface.messageComplete == NO) {
        [self editChunk:chunkIdx];
    }
}




-(void)editChunk:(NSUInteger) idx{
    
    __block KETile *newTile = nil;
    
    // delete any existing tiles
    //[self deleteChunkTiles];
    
    //    [self.tileSystem pushCurPositionNewLineAndIndent];
    
    // walk the chunks
    [self.dataInterface enumerateChunksAtIndex:idx chunks:^(KTMethodChunk *aChunk) {
        newTile = [self.tileSystem newTile];
        //newTile.display = [self prettyString:aNode.name];
        newTile.display = aChunk.name;
        newTile.dataObject = aChunk;
        [self.tilesToDelete addObject:newTile];
        [newTile blockWhenClicked:^(KTMethodChunk *aChunk, KETile *tileThatWasClicked) {
            // select this chunk
            [self.dataInterface setChunkIdx:idx with:aChunk];
            
            // recurse
            [self refreshTiles];
        }];
        
    } done:^(KTMethod *aMethod) {
        newTile = [self.tileSystem newTile];
        newTile.display = @"DONE";
        [self.tilesToDelete addObject:newTile];
        [newTile blockWhenClicked:^(KTMethodChunk *aChunk, KETile *tileThatWasClicked) {
            // delete these tiles
            //[self deleteTiles:self.tilesToDelete];
            
            //[self.tileSystem popPosition];
            //[self.tileSystem pushCurPositionNewLineAndIndent];
            
            // recurse
            [self refreshTiles];
        }];
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
