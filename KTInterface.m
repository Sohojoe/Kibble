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
            // look for initer functions
            NSMutableDictionary *buildNodes = [NSMutableDictionary new];
            
            [self.curClass enumerateClassIniters:^(KTMethod *aMethod) {
                
                NSString *name = aMethod.name;
                if (aMethod.params.count) {
                    KTMethodParam *param = aMethod.params[0];
                    name = param.name;
                }
                
                KTMethodNode *aNode = [buildNodes objectForKey:name];
                
                if (aNode) {
                    [aNode.methods addObject:aMethod];
                    
                } else {
                    aNode = [KTMethodNode new];
                    
                    aNode.methods = [NSMutableOrderedSet new];
                    [aNode.methods addObject:aMethod];
                    aNode.methodParm = nil;
                    aNode.name = name;

                    if (aMethod.params.count) {
                        aNode.subNodesCount = aMethod.params.count;
                        if (aMethod.params.count<=1) {
                            aNode.nodeCanTerminate = YES;
                        }
                    } else {
                    }
                    [buildNodes setObject:aNode forKey:name];
                    [self.masterNodes addObject:aNode];
                }
                
            }];
        } else {
            //
        }
    }
    NSOrderedSet *s = [NSOrderedSet orderedSetWithOrderedSet:self.masterNodes];
    return s;
}
-(void)setCurNode:(KTMethodNode *)aNode{
    curNode = aNode;
}



//-------------------------------------
//-- helpers
-(void)enumerateKeyWordsIn:(NSString*)thisString calling:(void(^)(NSString*substring))block{
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
    [mutableInputString enumerateSubstringsInRange:NSMakeRange(0, mutableInputString.length) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        block(substring);
    }];
    
}


@end
