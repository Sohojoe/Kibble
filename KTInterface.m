//
//  KTInterface.m
//  Kibble
//
//  Created by Joe on 3/26/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KTInterface.h"

@implementation KTMethodNode
//@property (strong, nonatomic) KTMethod *method;
//@property (strong, nonatomic) KTMethodParam *methodParm;
//@property (nonatomic) NSUInteger subNodesCount;
-(void)listSubNodes:(void(^)(NSOrderedSet* subNodes))block{
    
}
//@property (nonatomic) BOOL nodeCanTerminate;
@end

@interface KTInterface ()
@property (nonatomic, strong) NSMutableOrderedSet *masterClasses;
@property (nonatomic, strong) NSMutableOrderedSet *masterNodes;
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
}

// --------------------------------
// node interface


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
                aNode.methodParm = aParam;
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
                aNode.nodeIsParamTerminator = YES;
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
        
        if ((aNode.nodeCanTerminate && aNode.nodeTreeChildren.count) ||
            (aNode.nodeIsParamTerminator && aNode.nodeTreeChildren.count)) {
            // add
            [newTree setObject:aNode forKey:aNode.name];
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

    

-(void)oldcollapseTree:(NSMutableDictionary*)aTree{
    [aTree enumerateKeysAndObjectsUsingBlock:^(id key, KTMethodNode *aNode, BOOL *stop) {
        
        if (aNode.nodeTreeChildren.count == 1 &&
            aNode.nodeCanTerminate == NO) {
            // one child
            NSEnumerator *oe = [aNode.nodeTreeChildren objectEnumerator];
            KTMethodNode *childNode = [oe nextObject];
            childNode.name = [aNode.name stringByAppendingString:childNode.name];
            aNode = childNode;
            
            //[aNode.nodeTreeChildren enumerateKeysAndObjectsUsingBlock:^(id key, KTMethodNode *childNode, BOOL *stop) {
                // collopase into the child
                //aNode.name = [aNode.name stringByAppendingString:childNode.name];
                //aNode.nodeTreeChildren = childNode.nodeTreeChildren;
            //}];
            
            
        } else if (aNode.nodeTreeChildren.count > 1) {
            // more than one child
            
            
        } else {
            // no children
        }
        if (aNode.nodeTreeChildren) {
            // just walk through the kids
            //[self collapseTree:aNode.nodeTreeChildren];
        }
        
    }];
}

//-------------------------------------
//-- helpers
-(void)enumerateKeyWordsIn:(KTMethod *)aMethod calling:(void(^)(NSString *substring, NSString *appendedSubstring, KTMethodParam *forParam))block{
    if (aMethod.params.count) {
        [aMethod.params enumerateObjectsUsingBlock:^(KTMethodParam *aMethodParm, NSUInteger idx, BOOL *stop) {
            NSString *name = aMethodParm.name;
            if (idx < aMethod.params.count) {
                [name stringByAppendingString:@":"];
            }
                [self enumerateKeyWords:name for:aMethodParm calling:block];
        }];
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
