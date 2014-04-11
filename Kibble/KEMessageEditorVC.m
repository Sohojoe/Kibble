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
#import "UIAlertViewBlock.h"


@interface KEMessageEditorVC ()
@property (nonatomic, strong) KTInterface *dataInterface;
@property (nonatomic, strong) KETileSystem *tileSystem;
@property (nonatomic, strong) void(^successBlock)(KTMessage *newMessage);
@property (nonatomic, strong) KEPickFromSet *pickSetInterface;
@property (nonatomic, strong) KEMessageEditorVC *paramInterface;
@property (nonatomic, strong) NSMutableSet *tilesToDelete;
@end

@implementation KEMessageEditorVC

+(instancetype)messageEditorUsing:(KTInterface*)aDataInterface using:(KETileSystem*)aTileSystem then:(void (^)(KTMessage *newMessage))aSuccessBlock{
    KEMessageEditorVC *o = [KEMessageEditorVC new];
    
    // set up class
    o.dataInterface = aDataInterface;
    o.tileSystem = [aTileSystem sublayerTileSystem];
    o.successBlock = aSuccessBlock;
    o.tilesToDelete = [NSMutableSet new];
    
    __weak typeof(o) weakSelf = o;
    o.dataInterface.callWithCompletedMessage = ^(KTMessage *aMessage){
        if ([aMessage isKindOfClass:[KTMessage class]] == NO) {
            // it's an object
            weakSelf.dataInterface.theMessage.targetObject = aMessage;
        }
        
        if (weakSelf.successBlock) {
            weakSelf.successBlock(aMessage);
        }
    };
    
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

-(void)pickFromSet:(NSOrderedSet*)aSet then:(void (^)(id selectedObject))aSuccessBlock{

    // dismiss interfaces
    if (self.pickSetInterface) {
        [self.pickSetInterface dismiss];
    }
    if (self.paramInterface) {
        [self.paramInterface dismiss];
    }
    
    self.pickSetInterface = [KEPickFromSet pickFromSet:aSet using:self.tileSystem then:aSuccessBlock];
}
-(void)createParamForIdx:(NSUInteger)idx then:(void (^)(KTMessage *newMessage))aSuccessBlock{
    // dismiss interfaces
    if (self.pickSetInterface) {
        [self.pickSetInterface dismiss];
    }
    if (self.paramInterface) {
        [self.paramInterface dismiss];
    }
    
    KTMethodParam *aParam = [self.dataInterface.theMessage paramSyntaxAtIdx:idx];
    NSString *className = aParam.paramType.name;
    if (aParam.paramType.pointee) {
        className = aParam.paramType.pointee.name;
    }
    KTInterface *dataInterface = [KTInterface interfaceForClassNamed:className];

    self.paramInterface = [KEMessageEditorVC messageEditorUsing:dataInterface using:self.tileSystem then:aSuccessBlock];
    
    dataInterface.callWithCompletedMessage = ^(KTMessage *aMessage){
        if (self.paramInterface.successBlock) {
            [self.dataInterface.theMessage setParamMessageAtIdx:idx withMessageOrObject:aMessage];
            self.paramInterface.successBlock(aMessage);
        }
        
    };

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
        
        [self pickFromSet:foundationSet then:^(id selectedObject) {
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
        [self pickFromSet:classesSet then:^(id selectedObject) {
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
    id result = nil;
    if (self.dataInterface.messageComplete) {
        result = [self.dataInterface.theMessage sendMessage];
    }
    if (result == [KTMessage blankMessage] ||
        result == nil) {
        newTile.display = [self prettyString:self.dataInterface.curClass.name];
    } else {
        newTile.display = [result description];
    }
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
            [self.tilesToDelete addObject:newTile];
            
            __weak __block id paramData = [self.dataInterface.theMessage paramResultOrObjectAtIdx:idx];
            if (paramData == nil || paramData == [NSNull class]) {
                newTile.display = [NSString stringWithFormat:@"+\n(%@)", aChunk.param.paramType];

                [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
                    [self createParamForIdx:idx then:^(KTMessage *newMessage) {
                        [self redrawTiles];
                    }];
                }];
            } else {
                newTile.display = [paramData description];
                [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
                    [self createParamForIdx:idx then:^(KTMessage *newMessage) {
                        [self redrawTiles];
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
    
    if (idx == 0) {
        if ([self canInitCurClassFromInput]) {
            [chunkSet addObject:[KBEditorObject editorObjectFromInput]];
        }
    }
    
    // walk the chunks
    [self.dataInterface enumerateChunksAtIndex:idx chunks:^(KTMethodChunk *aChunk) {
        [chunkSet addObject:aChunk];
        
        
    } done:^(KTMethod *aMethod) {
        [chunkSet addObject:[KBEditorObject editorObjectDone]];
    }];
    
    [self pickFromSet:chunkSet then:^(id selectedObject) {
        if ([selectedObject isKindOfClass:[KTMethodChunk class]]) {
            // select this chunk
            [self.dataInterface setChunkIdx:idx with:selectedObject];
            // recurse
            [self redrawTiles];
        } else if ([selectedObject isKindOfClass:[KBEditorObject class]]) {
            if ([selectedObject isTypeFromInput]) {
                // get from input
                [self inputFromString:^(NSString *inputStr) {
                    id result = [self dataObjectFrom:inputStr];
                    // select this object
                    [self.dataInterface setIndex:idx with:result];
                    
                    // ensure the message is tydy
                    //[self.dataInterface.theMessage deleteParamFromIdx:idx];
                    //[self.dataInterface.theMessage setParamMessageAtIdx:idx withMessage:result];
                    // recurse
                    [self redrawTiles];
                }];
            }
        } else {
            // recurse
            [self redrawTiles];
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


/// YES if this can be taken from a string input
-(BOOL)canInitCurClassFromInput{
    BOOL res = NO;
    
    res |= [self isCurClassFromInputCompatableString];
    res |= [self isCurClassFromInputCompatableNumber];
    
    return res;
}
-(BOOL)isCurClassFromInputCompatableString{
    BOOL res = NO;
    if ([self.dataInterface.theMessage.targetObject isKindOfClass:[NSString class]] ||
        self.dataInterface.theMessage.targetObject == [NSString class]){
        res = YES;
    }
    return res;
}
-(BOOL)isCurClassFromInputCompatableNumber{
    BOOL res = NO;
    if ([self.dataInterface.theMessage.targetObject isKindOfClass:[NSNumber class]] ||
        self.dataInterface.theMessage.targetObject == [NSNumber class]){
        res = YES;
    }
    return res;
}


/// convert a text input into the best fit of data
-(id)dataObjectFrom:(NSString*)anInputString{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    
    if ([self isCurClassFromInputCompatableNumber]) {
        if ([self.dataInterface.theMessage.targetObject isKindOfClass:[NSDecimalNumber class]] ||
            self.dataInterface.theMessage.targetObject == [NSDecimalNumber class] ) {
            f.generatesDecimalNumbers = YES;
        }
        [f setNumberStyle:NSNumberFormatterNoStyle];
        NSNumber * aNumber = [f numberFromString:anInputString];
        return aNumber;
    } else if ([self isCurClassFromInputCompatableString]) {
        return anInputString;
    }
    
    f.generatesDecimalNumbers = YES;
    [f setNumberStyle:NSNumberFormatterNoStyle];
    NSNumber * aNumber = [f numberFromString:anInputString];
    if (aNumber) {
        return aNumber;
    }
    
    /*
     [f setNumberStyle:NSNumberFormatterSpellOutStyle];
     f.generatesDecimalNumbers = YES;
     aNumber = [f numberFromString:anInputString];
     if (aNumber) {
     return aNumber;
     }
     */
    return anInputString;
}
/// input from string
-(void)inputFromString:(void (^)(NSString *inputStr))aSuccessBlock{
    __block UIAlertViewBlock *alert = [[UIAlertViewBlock alloc] initWithTitle:@"Create Kibble From Input"
                                                                      message:@"Type in a string or number\n"
                                                                   completion:^(BOOL cancelled, NSInteger buttonIndex)
                                       {
                                           if(cancelled) {
                                               
                                           } else {
                                               // success
                                               if (aSuccessBlock) aSuccessBlock([alert textFieldAtIndex:0].text);
                                               }
                                       }
                                                            cancelButtonTitle:@"CANCEL"
                                                            otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //[alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alert textFieldAtIndex:0].placeholder = @"...";
    [alert show];
    
}

@end
