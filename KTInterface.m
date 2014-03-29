//
//  KTInterface.m
//  Kibble
//
//  Created by Joe on 3/26/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KTInterface.h"

@implementation KTMethodNode

-(id)copyWithZone:(NSZone *)zone {
    KTMethodNode *copy = [[[self class] alloc] init];
    
    if (copy) {
        // Copy NSObject subclasses
        copy.methods = [NSMutableOrderedSet orderedSetWithOrderedSet:self.methods];
        copy.name = [NSString stringWithString:self.name];
        copy.appendedName = [NSString stringWithString:self.appendedName];
        copy.nodeCanTerminate = self.nodeCanTerminate;
        copy.nodeTreeChildren = [NSMutableDictionary dictionaryWithDictionary:self.nodeTreeChildren];
    }
    
    return copy;
}
@end

@implementation KTMethodChunk
+(instancetype)chunkWith:(NSString*)aName apppended:(NSString*)aAppendedName requires:(BOOL)doesRequireParam{
    KTMethodChunk *aChunk = [KTMethodChunk new];
    if (aChunk) {
        aChunk.name = aName;
        aChunk.appendedName = aAppendedName;
        aChunk.requiresParam = doesRequireParam;
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
@end

@interface KTInterface ()
@property (nonatomic, strong) NSMutableOrderedSet *masterClasses;
@property (nonatomic, strong) NSMutableOrderedSet *masterNodes;
@property (nonatomic, strong) NSMutableDictionary *masterChunks;
@property (nonatomic, strong) NSMutableDictionary *activeChunks;
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

@synthesize foundations, classes, nodes, foundation, curClass, curNode;
@synthesize paramContent, paramList;
// --------------------------------
// lazy
-(NSMutableOrderedSet*)paramList{
    if (paramList == nil) {
        paramList = [NSMutableOrderedSet new];
    }
    return paramList;
}
-(NSMutableOrderedSet*)paramContent{
    if (paramContent == nil) {
        paramContent = [NSMutableOrderedSet new];
    }
    return paramContent;
}


// --------------------------------
// foundation interface
-(void)setFoundation:(KTFoundation *)aFoundation{
    foundation = aFoundation;
    self.masterClasses = nil;
    self.masterNodes = nil;
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
-(void)setCurClass:(KTClass *)aClass{
    curClass = aClass;
    self.masterNodes = nil;
    [self buildChunks];
}

// --------------------------------
// chunk interface
-(void)buildChunks{
    // initers
    self.masterChunks = [NSMutableDictionary new];
    self.activeChunks = self.masterChunks;
    self.chunkList = [NSMutableOrderedSet new];
    
    [self.curClass enumerateClassIniters:^(KTMethod *aMethod) {
        
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
                    aChunk = [KTMethodChunk chunkWith:name apppended:appendedString requires:YES];
                    if (parentChunk == nil) {
                        // add to chunks as we are a root
                        NSLog(@"%@", aChunk);
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
                aChunk = [KTMethodChunk chunkWith:aMethod.name apppended:aMethod.name requires:NO];
                NSLog(@"%@", aChunk);
                [self.masterChunks setObject:aChunk forKey:aMethod.name];
            }
            [aChunk completeWith:aMethod];
        }
    }];
    
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
-(void)selectChunk:(KTMethodChunk*)aChunk{
    [self.chunkList addObject:aChunk];
    if (aChunk.requiresParam) {
        
    }
    if (aChunk.brancesTo.count) {
        self.activeChunks = aChunk.brancesTo;
    }
        
}

// --------------------------------
// node interface
-(void)setCurNode:(KTMethodNode *)aNode{
    curNode = aNode;
    
    if (aNode.nodeCanTerminate) {
        NSEnumerator *en = [aNode.methods objectEnumerator];
        KTMethod *aMethod = [en nextObject];
        KTMethodParam *aParam = [aMethod.params objectAtIndex:self.paramIdx];
        if (aParam) {
            [self.paramList setObject:aParam atIndex:self.paramIdx];
            self.needsParam = YES;
        }
        if (aNode.methods.count == 1) {
            self.method = aMethod;
        }
    }
}
-(void)setParamContentWith:(id)thisContent{
    if (thisContent == nil) {
        thisContent = [NSNull null];
    }
    [self.paramContent setObject:thisContent atIndex:self.paramIdx];
    self.needsParam = NO;
    
    // reset the nodes
    self.masterNodes = nil;
    self.curNode = nil;
    
    self.paramIdx++;
    if(self.method) {
        if (self.paramIdx > self.method.params.count) {
            // done
        }
    }
}


-(NSOrderedSet*)nodes{
    if (self.masterNodes == nil) {
        self.masterNodes = [NSMutableOrderedSet new];
        if (self.initerMode) {


            // collapse tree where there is no split
            NSMutableDictionary *nodeTreeRoot = [NSMutableDictionary new];
            [self collapseTree:[self nodeTreeForIniters] into:nodeTreeRoot];
            
            // add trees to master
            [nodeTreeRoot enumerateKeysAndObjectsUsingBlock:^(id key, KTMethodNode *aNode, BOOL *stop) {
                [self.masterNodes addObject:aNode];
            }];
        
        } else {
            //
        }
    } else if (self.curNode) {
        self.masterNodes = [NSMutableOrderedSet new];
        NSMutableDictionary *nodeTreeRoot = self.curNode.nodeTreeChildren;
        
        // collapse tree where there is no split
        [self collapseTree:self.curNode.nodeTreeChildren into:nodeTreeRoot];
        
        // add trees to master
        [nodeTreeRoot enumerateKeysAndObjectsUsingBlock:^(id key, KTMethodNode *aNode, BOOL *stop) {
            [self.masterNodes addObject:aNode];
        }];
    }
    
    NSOrderedSet *s = [NSOrderedSet orderedSetWithOrderedSet:self.masterNodes];
    return s;
}

-(NSMutableDictionary*)nodeTreeForIniters{
    // look for initer functions
    NSMutableDictionary *nodeTreeRoot = [NSMutableDictionary new];
    
    [self.curClass enumerateClassIniters:^(KTMethod *aMethod) {
        //
        __block NSMutableDictionary *nodeTree = nodeTreeRoot;
        
        [self enumerateKeyWordsIn:aMethod calling:^(NSString *nodeName, NSString *nodeAppendedName, KTMethodParam *aParam) {
            
            KTMethodNode *aNode = [nodeTree objectForKey:nodeName];
            
            if (aNode) {
                // this node name is in the tree
                [aNode.methods addObject:aMethod];
                
            } else {
                // not in tree, lets create it and add it
                aNode = [KTMethodNode new];
                
                aNode.methods = [NSMutableOrderedSet new];
                [aNode.methods addObject:aMethod];
                aNode.name = nodeName;
                aNode.appendedName = nodeAppendedName;
                aNode.nodeTreeChildren = [NSMutableDictionary new];
                
                //if (aMethod.params.count) {
                //    aNode.subNodesCount = aMethod.params.count;
                //} else {
                //}
                // add to tree
                [nodeTree setObject:aNode forKey:nodeName];
            }
            
            // look to see if this node can end
            if (aMethod.params.count == 0) {
                aNode.nodeCanTerminate = YES;
            }
            // look see if this the end of a param
            if ([aParam.name isEqualToString:aNode.appendedName]) {
                aNode.nodeCanTerminate = YES;
                //aNode.nodeIsParamTerminator = YES;
            }
            
            // set nodeTree to child of this tree
            nodeTree = aNode.nodeTreeChildren;
        }];
    }];
    
    return nodeTreeRoot;
}


-(void)collapseTree:(NSMutableDictionary*)aTree into:(NSMutableDictionary*)newTree{
    if (newTree == nil) {
        newTree = [NSMutableDictionary new];
    }
    
    [aTree enumerateKeysAndObjectsUsingBlock:^(id key, KTMethodNode *aNode, BOOL *stop) {
        
        if ((aNode.nodeCanTerminate && aNode.nodeTreeChildren.count)){
            __block KTMethod *aMethod = nil;
            [aNode.methods enumerateObjectsUsingBlock:^(KTMethod *thisMethod, NSUInteger idx, BOOL *stop) {
                if ([thisMethod.name isEqualToString:aNode.name]) {
                    aMethod = thisMethod;
                }
            }];
            KTMethodNode *newNode = [aNode copy];
            newNode.methods = [NSMutableOrderedSet new];
            if (aMethod) {
                [newNode.methods addObject:aMethod];
                [aNode.methods removeObject:aMethod];
            }
            [newTree setObject:newNode forKey:newNode.name];
            aNode.nodeCanTerminate = NO;
        }
        
        while (aNode.nodeTreeChildren.count == 1) {
            // collapse child into me
            NSEnumerator *oe = [aNode.nodeTreeChildren objectEnumerator];
            KTMethodNode *childNode = [oe nextObject];
            childNode.name = [aNode.name stringByAppendingString:childNode.name];
            aNode = childNode;
        }
        
        if (aNode.nodeTreeChildren.count >1) {
            // recerse
            NSMutableDictionary *newTreeBranch = [NSMutableDictionary new];
            [self collapseTree:aNode.nodeTreeChildren into:newTreeBranch];
            aNode.nodeTreeChildren = newTreeBranch;
            if ([aNode.name hasSuffix:@"…"] == NO) {
                aNode.name = [aNode.name stringByAppendingString:@"…"];
            }
            [newTree setObject:aNode forKey:aNode.name];
        } else {
            [newTree setObject:aNode forKey:aNode.name];
        }
    }];
}




//-------------------------------------
//-- helpers
-(void)enumerateKeyWordsIn:(KTMethod *)aMethod calling:(void(^)(NSString *substring, NSString *appendedSubstring, KTMethodParam *forParam))block{
    if (aMethod.params.count) {
        KTMethodParam *aMethodParm = [aMethod.params objectAtIndex:self.paramIdx];

        NSString *name = aMethodParm.name;
        if (self.paramIdx < aMethod.params.count) {
            [name stringByAppendingString:@":"];
        }
        [self enumerateKeyWords:name for:aMethodParm calling:block];
        
        /*        [aMethod.params enumerateObjectsUsingBlock:^(KTMethodParam *aMethodParm, NSUInteger idx, BOOL *stop) {
            NSString *name = aMethodParm.name;
            if (idx < aMethod.params.count) {
                [name stringByAppendingString:@":"];
            }
                [self enumerateKeyWords:name for:aMethodParm calling:block];
        }];
 */
    } else {
        [self enumerateKeyWords:aMethod.name for:nil calling:block];
    }
}


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
