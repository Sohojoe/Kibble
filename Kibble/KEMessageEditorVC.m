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
#import "KTObject.h"


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
    o.dataInterface.callWithCompletedMessageOrObject = ^(id aMessageOrObject){
        if ([aMessageOrObject isKindOfClass:[KTObject class]]) {
            // it's an object
            weakSelf.dataInterface.targetObject = aMessageOrObject;
        }
        
        if (weakSelf.successBlock) {
            weakSelf.successBlock(aMessageOrObject);
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

    
    if (self.dataInterface.targetObject == nil) {
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
    KTInterface *dataInterface = nil;
    if (aParam.paramType.isCType) {
        // it's a C type
        NSValue *aValue = [aParam.paramType nillValue];
        dataInterface = [KTInterface interfaceForCType:aValue ofType:aParam.paramType];
    } else {
        // it's an objective C type
        dataInterface = [KTInterface interfaceForClassNamed:className];
    }

    self.paramInterface = [KEMessageEditorVC messageEditorUsing:dataInterface using:self.tileSystem then:aSuccessBlock];
    
    dataInterface.callWithCompletedMessageOrObject = ^(id aMessageOrObject){
        if (self.paramInterface.successBlock) {
            [self.dataInterface setParamAtIdx:idx withMessageOrObject:aMessageOrObject];
            self.paramInterface.successBlock(aMessageOrObject);
        }
        
    };

}

//------------------------------------------------------------------------
//--
// Chooses foundand then class
// used when creating objects from nothing

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
    else if (self.dataInterface.targetObject == nil) {

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
                KTClass *aClass = selectedObject;
                KTObject *ktObject = [KTObject objectFor:NSClassFromString(aClass.name) from:NSClassFromString(aClass.name)];
                self.dataInterface.targetObject = ktObject;
            }
            
            // recurse
            [self redrawTiles];
        }];
    }
}

//------------------------------------------------------------------------
//--
//
-(void)editMessage{
    __block KETile *newTile = nil;
    
    // add tile to represent the targetObject
    [self addTargetObjectAsTyle];

    
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
            
            __weak __block id paramData = [self.dataInterface.theMessage paramMessageResultOrObjectAtIdx:idx];
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
    if (self.dataInterface.messageSyntaxIsValidMessage && self.dataInterface.messageHasMoreChunks) {
        newTile = [self.tileSystem newTile];
        newTile.display = @"+";
        [self.tilesToDelete addObject:newTile];
        [newTile blockWhenClicked:^(id obj, KETile *tileThatWasClicked) {
            [self editChunk:chunkIdx];
        }];
    }
    
    //if (self.dataInterface.messageComplete == NO) {
        [self editChunk:chunkIdx];
    //}
}

-(void)addTargetObjectAsTyle{
    __block KETile *newTile = [self.tileSystem newTile];

    // handle what to display
    id objText = nil;
    id outputText = nil;
    
    NSString *messageStr = [[self.dataInterface ifReadySendMessage] description];
    NSString *objectStr = [self.dataInterface.targetObject description];
    NSString *classStr = [self.dataInterface.targetObject.theObjectClass description];
    
    outputText = [NSString stringWithFormat:@"output = \n%@", messageStr];
    objText = objectStr;
    if (objText == nil) {
        objText = classStr;
    }
    newTile.display = objText;
    
    [self.tilesToDelete addObject:newTile];
    
    [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {

        // if complete
        if (self.dataInterface.messageSyntaxIsValidMessage) {
            // set outcome as the target object
            
            KTObject *returnObject = [self.dataInterface ifReadySendMessage];
            
            self.dataInterface.targetObject = returnObject;
            
            // recurse
            [self redrawTiles];
        }
    }];
    
    // show output text
    newTile = [self.tileSystem newTile];
    newTile.display = outputText;
    [self.tilesToDelete addObject:newTile];
    

}


-(void)editChunk:(NSUInteger) idx{
    
    NSMutableOrderedSet *chunkSet = [NSMutableOrderedSet new];
    
    
    // walk the chunks
    [self.dataInterface enumerateChunksAtIndex:idx chunks:^(KTMethodChunk *aChunk) {
        [chunkSet addObject:aChunk];
    } done:^(KTMethod *aMethod) {
        [chunkSet addObject:[KBEditorObject editorObjectDone]];
    }];

    // sort
    [chunkSet sortUsingComparator:(NSComparator)^(KTMethodChunk * obj1, KTMethodChunk * obj2){
        return [obj1.name localizedCaseInsensitiveCompare:obj2.name];
    }];
    
    if (idx == 0) {
        if ([self canInitTargetObjectFromInput]) {
            if (chunkSet) {
                [chunkSet insertObject:[KBEditorObject editorObjectFromInput] atIndex:0];
            } else {
                [chunkSet addObject:[KBEditorObject editorObjectFromInput]];
            }
        }
    }

    
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

                    [self.dataInterface completeUsingObject:result];
                    
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
-(BOOL)canInitTargetObjectFromInput{
    BOOL res = NO;
    
    res |= [self isTargetObjectFromInputCompatableString];
    res |= [self isTargetObjectFromInputCompatableNumber];
    
    return res;
}
-(BOOL)isTargetObjectFromInputCompatableString{
    BOOL res = NO;
    if ([self.dataInterface.targetObject.theObject isKindOfClass:[NSString class]] ||
        [self doesObject:self.dataInterface.targetObject.theObjectClass aClassOrDecendantClassOf:[NSString class]]){
        res = YES;
    }
    return res;
}
-(BOOL)doesObject:(id)aObject aClassOrDecendantClassOf:(Class)aClass{
    if (aObject == aClass) {
        return YES;
    } else if ([aObject superclass]) {
        return ([self doesObject:[aObject superclass] aClassOrDecendantClassOf:aClass]);
    }
    return NO;
}
-(BOOL)isTargetObjectFromInputCompatableNumber{
    BOOL res = NO;
    if ([self.dataInterface.targetObject.theObject isKindOfClass:[NSNumber class]] ||
        [self doesObject:self.dataInterface.targetObject.theObjectClass aClassOrDecendantClassOf:[NSNumber class]])
    {
        res = YES;
    } else if (self.dataInterface.targetObject.isCType) {
        res = YES;
    }
    return res;
}


/// convert a text input into the best fit of data
-(id)dataObjectFrom:(NSString*)anInputString{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    
    if ([self isTargetObjectFromInputCompatableNumber]) {
        if ([self.dataInterface.targetObject.theObject isKindOfClass:[NSDecimalNumber class]] ||
            self.dataInterface.targetObject.theObjectClass == [NSDecimalNumber class] ) {
            f.generatesDecimalNumbers = YES;
        }
        [f setNumberStyle:NSNumberFormatterNoStyle];
        NSNumber * aNumber = [f numberFromString:anInputString];
        return aNumber;
    } else if ([self isTargetObjectFromInputCompatableString]) {
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
                                               NSString *output = [NSString stringWithString:[alert textFieldAtIndex:0].text];
                                               if (aSuccessBlock) aSuccessBlock(output);
                                               }
                                       }
                                                            cancelButtonTitle:@"CANCEL"
                                                            otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    if ([self isTargetObjectFromInputCompatableNumber]) {
        [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    }
    [alert textFieldAtIndex:0].returnKeyType = UIReturnKeyGo;
    [alert textFieldAtIndex:0].placeholder = @"...";
    [alert show];
    
}

@end
