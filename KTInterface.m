//
//  KTInterface.m
//  Kibble
//
//  Created by Joe on 3/26/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KTInterface.h"
#import "KTMessage.h"
#import "KTObject.h"



@implementation KTMethodChunk
+(instancetype)chunkWith:(NSString*)aName apppended:(NSString*)aAppendedName{
    KTMethodChunk *aChunk = [KTMethodChunk new];
    if (aChunk) {
        aChunk.name = aName;
        aChunk.appendedName = aAppendedName;
        aChunk.brancesTo = [NSMutableDictionary new];
    }
    return aChunk;
}
+(instancetype)chunkWith:(NSString*)aName apppended:(NSString*)aAppendedName param:(KTMethodParam*)aParam{
    KTMethodChunk *aChunk = [KTMethodChunk new];
    if (aChunk) {
        aChunk.name = aName;
        aChunk.appendedName = aAppendedName;
        aChunk.requiresParam = YES;
        aChunk.param = aParam;
        aChunk.brancesTo = [NSMutableDictionary new];
    }
    return aChunk;
}
-(void)completeWith:(KTMethod *)aMethod{
    [self.brancesTo setObject:aMethod forKey:@"done"];
}
-(void)addChild:(KTMethodChunk *)aChunk{
    [self.brancesTo setObject:aChunk forKey:aChunk.name];
}
-(NSString*)description{
    return self.name;
}
-(NSString*)debugDescription{
    NSMutableString *output = [NSMutableString stringWithFormat:@"%@",self.name];
    [output appendFormat:@", %@",self.appendedName];
    if (self.requiresParam) {
        [output appendString:@", requiresParam = TRUE"];
    } else {
        [output appendString:@", requiresParam = FALSE"];
    }
    if (self.brancesTo.count) {
        [output appendString:@", brancesTo <"];
        [self.brancesTo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [output appendFormat:@"%@, ",key];
        }];
        [output appendString:@">"];
    }
 
    return output;
}
-(KTType*)returnType{
    __block KTType *aReturnType = nil;
    [self.brancesTo enumerateKeysAndObjectsUsingBlock:^(NSString *key, KTMethod *thisMethod, BOOL *stop) {
        if ([key isEqualToString:@"done"]) {
            KTType *thisReturnType = thisMethod.returns;
            aReturnType = thisReturnType;
            *stop = YES;
        }
    }];
    return aReturnType;
}
@end

@interface KTInterface ()
@property (nonatomic, strong) NSMutableOrderedSet *masterClasses;
@property (nonatomic, strong) NSMutableDictionary *masterChunks;
@property (nonatomic, strong) NSMutableDictionary *activeChunks;
@property (nonatomic, strong) NSMutableOrderedSet *chunkList;


@end

@implementation KTInterface
static NSMutableSet *masterFoundationSet;
+(void)addFoundationFromDisk:(NSString*)foundationName{
    if (masterFoundationSet == nil) {
        masterFoundationSet = [NSMutableSet new];
    }
    [masterFoundationSet addObject:[KTFoundation foundationFromDisk:foundationName]];
}
+(instancetype)interface{
    KTInterface *o = [KTInterface new];
    return o;
}
+(instancetype)interfaceFromObject:(KTObject*)anObject{
    KTInterface *o = [KTInterface new];
    o.theMessage = [KTMessage new];
    o.targetObject = anObject;
    return o;
}
+(instancetype)interfaceForClassNamed:(NSString*)aClassName{
    KTInterface *o = [super new];
    KTObject *ktObject = [KTObject objectFor:NSClassFromString(aClassName) from:NSClassFromString(aClassName)];
    o.targetObject = ktObject; //[KTClass findClassWithName:aClassName]);
    return o;
}
-(instancetype)init{
    KTInterface *o = [super init];
    
    if (o) {
        
    }
    return o;
}
@synthesize foundations, classes, foundation, targetObject;


// --------------------------------
// foundation interface
-(void)setFoundation:(KTFoundation *)aFoundation{
    foundation = aFoundation;
    self.masterClasses = nil;
}
-(NSOrderedSet*)foundations{
    NSOrderedSet *fs = [NSOrderedSet orderedSetWithSet:masterFoundationSet];
    return fs;
}

// --------------------------------
// class interface
-(NSOrderedSet*)classes{
    if (self.masterClasses == nil) {
        self.masterClasses = [NSMutableOrderedSet new];
        [self.foundation enumerateClasses:^(KTClass *aClass) {
            [self.masterClasses addObject:aClass];
        }];
    }
    NSOrderedSet *s = [NSOrderedSet orderedSetWithOrderedSet:self.masterClasses];
    return s;
}
-(void)setTargetObject:(KTObject*)anObject{
    // is this the same type as the current messgae
    if (targetObject.theObjectClass == anObject.theObjectClass) {
        // same type
        if (self.theMessage == nil) {
            self.theMessage = [KTMessage new];
        }
        self.theMessage.targetObject = anObject;
        targetObject = anObject;
        [self buildChunks];
    }
    else {
        // different type
        self.theMessage = [KTMessage new];
        self.theMessage.targetObject = anObject;
        targetObject = anObject;
        [self buildChunks];
    }
    
}



// --------------------------------
// chunk interface
-(void)buildChunks{
    // initers
    self.masterChunks = [NSMutableDictionary new];
    self.activeChunks = self.masterChunks;
    self.chunkList = [NSMutableOrderedSet new];
    
    KTClass *curClass = [KTClass findClassOfObject:self.targetObject.theObjectClass];
    
    if (self.targetObject.isClassObject) {
        [curClass enumerateClassIniters:^(KTMethod *aMethod) {
            [self buildChunksDisplay:aMethod];
        }];
    } else if (self.theMessage.targetObject){
        // instance
        [curClass enumerateInterface:^(KTMethod *aClassMethod, KTMethod *anIntanceMethod, KTVariable *anInstanceVariable) {
            if (anIntanceMethod) {
                [self buildChunksDisplay:anIntanceMethod];
            }
            if (anInstanceVariable) {
                
            }
        }];
    } else {
        // class
        // TO FIX USE [KTClass findClassOfObject:anObject]
        [curClass enumerateClassMethods:^(KTMethod *aMethod) {
            [self buildChunksDisplay:aMethod];
        }];
    }
    
}

-(void)buildChunksDisplay:(KTMethod*) aMethod{
    if (aMethod.params.count) {
        // has params
        __block NSString *appendedString = @"";
        __block KTMethodChunk *parentChunk = nil;
        [aMethod.params enumerateObjectsUsingBlock:^(KTMethodParam *aParam, NSUInteger idx, BOOL *stop) {
            NSString *name = aParam.name;
            name = [name stringByAppendingString:@":"];
            appendedString = [appendedString stringByAppendingString:name];
            KTMethodChunk *aChunk = [self.masterChunks objectForKey:appendedString];
            if (aChunk == nil) {
                aChunk = [KTMethodChunk chunkWith:name apppended:appendedString param:aParam];
                if (parentChunk == nil) {
                    // add to chunks as we are a root
                    [self.masterChunks setObject:aChunk forKey:appendedString];
                }
            }
            if (parentChunk) {
                [parentChunk addChild:aChunk];
            }
            parentChunk = aChunk;
            // check if last
            if (idx >= aMethod.params.count-1) {
                // add done
                [aChunk completeWith:aMethod];
            }
            
        }];
    } else {
        KTMethodChunk *aChunk = [self.masterChunks objectForKey:aMethod.name];
        if (aChunk == nil) {
            aChunk = [KTMethodChunk chunkWith:aMethod.name apppended:aMethod.name];
            [self.masterChunks setObject:aChunk forKey:aMethod.name];
        }
        [aChunk completeWith:aMethod];
    }
}


-(void)enumerateChunksAtIndex:(NSUInteger)idx chunks:(void (^)(KTMethodChunk *aChunk)) chunksBlock done:(void (^)(KTMethod *aMethod)) doneBlock{
    self.activeChunks = self.masterChunks;
    if (idx && idx <= self.chunkList.count) {
        KTMethodChunk *aChunk = [self.chunkList objectAtIndex:idx-1];
        self.activeChunks = aChunk.brancesTo;
    }

    __block KTMethod *doneMethod = nil;
    [self.activeChunks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[KTMethodChunk class]]) {
            // we have a chunk
            if (chunksBlock) {
                KTMethodChunk *aChunk = obj;
                chunksBlock(aChunk);
            }
        } else if ([obj isKindOfClass:[KTMethod class]]) {
            // we have a chunk
            doneMethod = obj;
        }
    }];
    // check if we need to call the doneBlock, we do this last so it's at the end of the list
    if (doneBlock && doneMethod) {
        doneBlock(doneMethod);
    }


}

-(NSOrderedSet*)chunks{
    NSMutableOrderedSet *chunkSet = [NSMutableOrderedSet new];
    
    [self.activeChunks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[KTMethodChunk class]]) {
            // we have a chunk
            KTMethodChunk *aChunk = obj;
            [chunkSet addObject:aChunk];
        }
    }];
    
    // sort
    [chunkSet sortUsingComparator:(NSComparator)^(KTMethodChunk * obj1, KTMethodChunk * obj2){
        return [obj1.name localizedCaseInsensitiveCompare:obj2.name];
    }];
    
    NSOrderedSet *s = [NSOrderedSet orderedSetWithOrderedSet:chunkSet];
    return s;
}
-(void)setChunkIdx:(NSUInteger)idx with:(KTMethodChunk*)aChunk{
    
    _messageSyntaxIsValidMessage = NO;
    _messageHasMoreChunks = NO;
    _messageAllParamsAreValid = NO;
    self.theMessage.isValidAndComplete = NO;

    // check if we need to remove chunks
    while (self.chunkList.count > idx) {
        [self.chunkList removeObjectAtIndex:self.chunkList.count-1];
    }
    
    // ensure the message is tydy
    [self.theMessage deleteParamFromIdx:idx];
    
    // early exit if no new chunk
    if (aChunk == nil) {
        // no chunk, but need to tidy up
        if (idx) {
            // recurse with previous chunk
            [self setChunkIdx:idx-1 with:[self.chunkList objectAtIndex:idx-1]];
        } else {
            _messageSyntaxIsValidMessage = NO;
        }
        return;
    }
    
    // add this chunk
    [self.chunkList addObject:aChunk];
    if (aChunk.requiresParam) {
        [self.theMessage initParamAtIdx:idx withParam:(KTMethodParam*)aChunk.param];
    }
    
    // set return type
    NSString *returnClassName = aChunk.returnType.name;
    if (aChunk.returnType.pointee) {
        returnClassName = aChunk.returnType.pointee.name;
    }
    [self.theMessage setReturnedObjectClass:NSClassFromString(returnClassName)];
    
    if (aChunk.brancesTo.count) {
        self.activeChunks = aChunk.brancesTo;
        if (self.activeChunks.count == 1) {
            NSEnumerator *en = [self.activeChunks objectEnumerator];
            id obj = [en nextObject];
            if ([obj isKindOfClass:[KTMethodChunk class]]) {
                [self setChunkIdx:idx+1 with:obj];
            } else {
                // we are done
                _messageSyntaxIsValidMessage = YES;
                if (self.theMessage.isBlankMessage == NO) {
                    self.theMessage.isValidAndComplete = YES;
                }
            }
        } else {
            // we have more potential objects
            _messageHasMoreChunks = YES;
            [self.activeChunks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([key isEqualToString:@"done"]) {
                    // we are done
                    _messageSyntaxIsValidMessage = YES;
                }
            }];
        }
    }
    
    // build message name
    self.theMessage.messageName = @"";
    [self.chunkList enumerateObjectsUsingBlock:^(KTMethodChunk *aChunk, NSUInteger idx, BOOL *stop) {
        self.theMessage.messageName = [self.theMessage.messageName stringByAppendingString:aChunk.name];
    }];
    
    

    if (self.theMessage.isValidAndComplete) {
        if (self.callWithCompletedMessageOrObject) {
            self.callWithCompletedMessageOrObject(self.theMessage);
        }
    }
}
-(void)setIndex:(NSUInteger)idx withObject:(id)anObject ofClass:(Class) aClass{
    _messageSyntaxIsValidMessage = YES;
    
    if (self.callWithCompletedMessageOrObject) {
        KTObject *ktObject = [KTObject objectFor:anObject from:aClass];
        self.callWithCompletedMessageOrObject(ktObject);
    }
}


-(void)setParamAtIdx:(NSUInteger)idx withMessageOrObject:(id)aMessageOrObject{
    [self.theMessage setParamMessageAtIdx:idx withMessageOrObject:aMessageOrObject];
    
    if (self.theMessage.paramCount == self.chunkList.count) {
        // correct number of params have been filled in the message
        _messageAllParamsAreValid = YES;
    } else {
        // not enough params
        _messageAllParamsAreValid = NO;
    }
    self.theMessage.isValidAndComplete = self.messageAllParamsAreValid && self.messageSyntaxIsValidMessage;
}
-(id)ifReadySendMessage{
    KTObject *res = nil;
    if (self.theMessage.isValidAndComplete) {
        res = [self.theMessage sendMessage];
    }
    return res.theObject;
}



-(void)enumerateChunks:(void(^)(KTMethodChunk *aChunk, NSUInteger idx)) chunkBlock andParams:(void(^)(KTMethodParam *aParm, KTMethodChunk *aChunk, NSUInteger idx)) paramBlock{
    
    NSUInteger idx = 0;
    
    while (idx < self.chunkList.count) {
        if (chunkBlock) {
            chunkBlock(self.chunkList[idx], idx);
        }
        if (paramBlock) {
            if ([self.theMessage paramCount] > idx) {
                paramBlock([self.theMessage paramSyntaxAtIdx:idx], self.chunkList[idx], idx);
            }
        }
        idx++;
    }
    
}


//-------------------------------------
//-- helpers

-(void)enumerateKeyWords:(NSString*)thisString for:(KTMethodParam*) forParam calling:(void(^)(NSString *substring, NSString *appendedSubstring, KTMethodParam *forParam))block{
    if (!block){
        // early exit
        return;
    }
    
    int index = thisString.length;
    NSMutableString* mutableInputString = [NSMutableString stringWithString:thisString];
    
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
    
    //return [NSString stringWithString:mutableInputString];
    NSMutableString *appendedSubstring = [NSMutableString new];
    [mutableInputString enumerateSubstringsInRange:NSMakeRange(0, mutableInputString.length) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [appendedSubstring appendString:substring];
        block(substring, [NSString stringWithString:appendedSubstring], forParam);
    }];
    
}


@end
