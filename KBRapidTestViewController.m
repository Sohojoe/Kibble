//
//  KBRapidTestViewController.m
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KBRapidTestViewController.h"
#import "KBDatabase.h"
//#import "Kibble.h"
#import "KETileSystem.h"
//#import "KibbleTalk.h"
//@import JavaScriptCore;
#import "JSRnD.h"
#import "KibbleVM.h"
#import "KibbleV2.h"

#import "KTInterface.h"

@interface KBRapidTestViewController ()
//@property (nonatomic, strong) Kibble *hello;
//@property (nonatomic, strong) KibbleTalk *testNumber;
//@property (nonatomic, strong) KibbleTalk *oldSquare;

@property (nonatomic, strong) KETileSystem *tileSystem;
@property (nonatomic, strong) VMTalk *square;
@property (nonatomic, strong) VMTalk *multiply;
@property (nonatomic, strong) VMKode *testObject;
@property (nonatomic, strong) KibbleV2 *testKibble;
@end

@implementation KBRapidTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initForTest];
    [self test3];
}
-(void)initForTest{
    UIScrollView *sv = (UIScrollView *)self.view;
    if ([sv isKindOfClass:[UIScrollView class]]) {
        sv.scrollEnabled = YES;
    } else {
        sv = [UIScrollView new];
        CGRect frame = self.view.frame;
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft
            || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight){
            frame.size.width = self.view.bounds.size.height;
            frame.size.height = self.view.bounds.size.width;
        }
        
        
        sv.frame=frame;
        sv.contentSize = frame.size;
        [sv setScrollEnabled:YES];
        //[sv addSubview:imageView];
        [self.view addSubview:sv];
    }
    
    
    [KETileSystem defaultTileSystem].parentView = self.view;
    self.tileSystem = [KETileSystem tileSystemWithSquareTileSize:128.0 parentView:sv];
    [self.tileSystem editKibble:self.testKibble];
    
    [KTInterface addFoundationFromDisk:@"TestFoundation"];
}

-(void)test3{
    [self newKibble:^(BOOL success, id newKibble) {
        [self test3];
    }];
    
}

-(void)newKibble:(void (^)(BOOL success, id newKibble))successBlock{

    __block KETile *newTile = [self.tileSystem newTile];
    newTile.display = @"New\nKibble";
    newTile.dataObject = nil;
    __block NSMutableSet *tilesToDelete = [NSMutableSet new];
    //[tilesToDelete addObject:newTile];
    [newTile blockWhenClicked:^(KTFoundation *thisFoundation, KETile *tileThatWasClicked) {
        [self deleteTiles:tilesToDelete];
        
        [self.tileSystem popPosition];
        [self.tileSystem pushCurPositionNewLineAndIndent];
        
        KTInterface *dataInterface = [KTInterface interface];
        dataInterface.initerMode = YES;
        //NSMutableSet *tilesToDelete = [NSMutableSet new];
        [self walkInterfaceForIniter:dataInterface then:^(BOOL success, id newKibble) {
            //
        } with:tilesToDelete];
    }];
}
-(void)deleteTiles:(NSMutableSet*)tilesToDelete{
    [tilesToDelete enumerateObjectsUsingBlock:^(KETile *aTile, BOOL *stop) {
        [aTile dismiss];
    }];
    [tilesToDelete removeAllObjects];
    
}
-(void)newKibbleOld:(void (^)(BOOL success, id newKibble))successBlock{

    [self.tileSystem pushCurPositionNewLineAndIndent];
    
    KTInterface *kFace = [KTInterface interface];

    __block KETile *newTile = [self.tileSystem newTile];
    newTile.display = @"New\nKibble";
    newTile.dataObject = nil;
    __block NSMutableArray *tilesToDelete = [NSMutableArray new];
    [tilesToDelete addObject:newTile];
    [newTile blockWhenClicked:^(KTFoundation *thisFoundation, KETile *tileThatWasClicked) {
        // stop self from touches
        [tileThatWasClicked blockWhenClicked:nil];
        
        // add foundations
        [kFace.foundations enumerateObjectsUsingBlock:^(KTFoundation *thisFoundation, NSUInteger idx, BOOL *stop) {
            
            newTile = [self.tileSystem newTile];
            newTile.display = [self prettyString:thisFoundation.name];
            newTile.dataObject = thisFoundation;
            [tilesToDelete addObject:newTile];
            [newTile blockWhenClicked:^(KTFoundation *thisFoundation, KETile *tileThatWasClicked) {
                
                // set this as the foundation
                kFace.foundation = thisFoundation;
                
                // add classes
                [kFace.classes enumerateObjectsUsingBlock:^(KTClass *aClass, NSUInteger idx, BOOL *stop) {
                    
                    if ([aClass.name isEqualToString:@"NSString"] == NO) {
                        return;
                    }

                    newTile = [self.tileSystem newTile];
                    newTile.display = [self prettyString:aClass.name];
                    newTile.dataObject = aClass;
                    [tilesToDelete addObject:newTile];
                    [newTile blockWhenClicked:^(KTClass *aClass, KETile *tileThatWasClicked) {

                        // set this as the class
                        kFace.curClass = aClass;
                        
                        
                        // delete all the objects
                        [tilesToDelete enumerateObjectsUsingBlock:^(KETile *aTile, NSUInteger idx, BOOL *stop) {
                            [aTile dismiss];
                        }];
                        
                        [self.tileSystem popPosition];
                        [self.tileSystem pushCurPositionNewLineAndIndent];
                        newTile = [self.tileSystem newTile];
                        newTile.display = [self prettyString:aClass.name];
                        [tilesToDelete addObject:newTile];

                        [aClass enumerateClassIniters:^(KTMethod *aMethod) {
                            newTile = [self.tileSystem newTile];
                            newTile.display = [self prettyString:aMethod.name];
                            [tilesToDelete addObject:newTile];
                            [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
                                // delete all the objects
                                [tilesToDelete enumerateObjectsUsingBlock:^(KETile *aTile, NSUInteger idx, BOOL *stop) {
                                    [aTile dismiss];
                                }];
                                
                                // pop situation back to what we was
                                [self.tileSystem popPosition];
                                if (successBlock) successBlock(YES, dataObject);
                            }];
                        }];
                        
                        
                        
                    }];
                }];
            }];
            
            
        }];
        
        
        
    }];
    
}

-(void)walkInterfaceForIniter:(KTInterface*)dataInterface then:(void (^)(BOOL success, id newKibble))successBlock with:(NSMutableSet *)tilesToDelete{

    if (tilesToDelete == nil) {
        tilesToDelete = [NSMutableSet new];
    }
    __block KETile *newTile = nil;

    // if no foundation, select a foundation
    if (dataInterface.foundation == nil) {

        // add foundations
        [dataInterface.foundations enumerateObjectsUsingBlock:^(KTFoundation *thisFoundation, NSUInteger idx, BOOL *stop) {
            
            newTile = [self.tileSystem newTile];
            newTile.display = [self prettyString:thisFoundation.name];
            newTile.dataObject = thisFoundation;
            [tilesToDelete addObject:newTile];
            [newTile blockWhenClicked:^(KTFoundation *thisFoundation, KETile *tileThatWasClicked) {
                
                // set this as the class
                dataInterface.foundation = thisFoundation;
                
                // recurse
                [self walkInterfaceForIniter:dataInterface then:successBlock with:tilesToDelete];
            }];
        }];

    }
    
    // if no class, select a class
    else if (dataInterface.curClass == nil) {
        // add classes
        [dataInterface.classes enumerateObjectsUsingBlock:^(KTClass *aClass, NSUInteger idx, BOOL *stop) {
            
            if ([aClass.name isEqualToString:@"NSString"] == NO) {
                return;
            }
            
            newTile = [self.tileSystem newTile];
            newTile.display = [self prettyString:aClass.name];
            newTile.dataObject = aClass;
            [tilesToDelete addObject:newTile];
            [newTile blockWhenClicked:^(KTClass *aClass, KETile *tileThatWasClicked) {
                
                // set this as the class
                dataInterface.curClass = aClass;
                
                
                // delete all the objects
                [tilesToDelete enumerateObjectsUsingBlock:^(KETile *aTile, BOOL *stop) {
                    [aTile dismiss];
                }];
                
                [self.tileSystem popPosition];
                [self.tileSystem pushCurPositionNewLineAndIndent];

                // recurse
                [self walkInterfaceForIniter:dataInterface then:successBlock with:tilesToDelete];
            }];
        }];
    }
    
    // if no node, select an interface
    else {
        newTile = [self.tileSystem newTile];
        newTile.display = [self prettyString:dataInterface.curClass.name];
        [tilesToDelete addObject:newTile];
        
        if (dataInterface.curNode) {
            newTile = [self.tileSystem newTile];
            newTile.display = [self prettyString:dataInterface.curNode.appendedName];
            [tilesToDelete addObject:newTile];
        }
    
    // walk the nodes
        
        
        // add nodes
        [dataInterface.nodes enumerateObjectsUsingBlock:^(KTMethodNode *aNode, NSUInteger idx, BOOL *stop) {
            newTile = [self.tileSystem newTile];
            newTile.display = [self prettyString:aNode.name];
            newTile.dataObject = aNode;
            [tilesToDelete addObject:newTile];
            [newTile blockWhenClicked:^(KTMethodNode *aNode, KETile *tileThatWasClicked) {
                // set this as the class
                dataInterface.curNode = aNode;
                
                // delete all the objects
                [tilesToDelete enumerateObjectsUsingBlock:^(KETile *aTile, BOOL *stop) {
                    [aTile dismiss];
                }];
                
                [self.tileSystem popPosition];
                [self.tileSystem pushCurPositionNewLineAndIndent];
                
                // recurse
                [self walkInterfaceForIniter:dataInterface then:successBlock with:tilesToDelete];
            }];
        }];
    }
}


-(void)test2{

    
    KTFoundation *foundation = [KTFoundation foundationFromDisk:@"TestFoundation"];

    
    __block NSMutableArray *classTiles = [NSMutableArray new];
    __block NSMutableArray *methodTiles = [NSMutableArray new];

    KETile *newTile = [self.tileSystem newTile];
    newTile.display = [self prettyString:foundation.name];
    newTile.dataObject = foundation;
    [newTile blockWhenClicked:^(KTFoundation *thisFoundation, KETile *tileThatWasClicked) {
        
        // abort if we have sub tiles around
        if (classTiles.count ||
            methodTiles.count) {
            return;
        }

        
        [self.tileSystem pushCurPositionNewLineAndIndent];
        

        
        [thisFoundation enumerateClasses:^(KTClass *aClass) {
            
            // create class
            KETile *classTile = [self.tileSystem newTile];
            [classTiles addObject:classTile];
            classTile.display = [self prettyString:aClass.name];
            classTile.dataObject = aClass;
            [classTile blockWhenClicked:^(KTClass *thisClass, KETile *tileThatWasClicked) {
                
                // remove class tiles
                [self removeAndPopFrom:classTiles];
                
                __block NSUInteger count = 0;
                __block BOOL firstTile = YES;
                
                [thisClass enumerateClassMethods:^(KTMethod *aMethod) {

                    if (firstTile) {
                        [self.tileSystem pushCurPositionNewLineAndIndent];
                        firstTile = NO;
                    }
                    if (count ==0) {
                        KETile *headerTitle = [self.tileSystem newHeaderTile];
                        headerTitle.display = @"Class Methods";
                        [methodTiles addObject:headerTitle];
                    }
                    
                    KETile *methodTile = [self.tileSystem newTile];
                    [methodTiles addObject:methodTile];
                    methodTile.display = [self prettyString:aMethod.name];
                    methodTile.dataObject = aMethod;
                    [methodTile blockWhenClicked:^(KTClass *thisClass, KETile *tileThatWasClicked) {
                        // remove method tiles
                        [self removeAndPopFrom:methodTiles];
                    }];
                    count++;
                }];
                
                if (count) {
                    [self.tileSystem newLine];
                    count=0;
                }

                [thisClass enumerateInstanceMethods:^(KTMethod *aMethod) {

                    // new line if we need a new line
                    if (firstTile) {
                        [self.tileSystem pushCurPositionNewLineAndIndent];
                        firstTile = NO;
                    }
                    // header tile if first of this tyle
                    if (count ==0) {
                        KETile *headerTitle = [self.tileSystem newHeaderTile];
                        headerTitle.display = @"Instance Methods";
                        [methodTiles addObject:headerTitle];
                    }
                    
                    KETile *methodTile = [self.tileSystem newTile];
                    [methodTiles addObject:methodTile];
                    methodTile.display = [self prettyString:aMethod.name];
                    methodTile.dataObject = aMethod;
                    [methodTile blockWhenClicked:^(KTClass *thisClass, KETile *tileThatWasClicked) {
                        // remove method tiles
                        [self removeAndPopFrom:methodTiles];
                    
                    }];
                    count++;
                }];

                if (count) {
                    [self.tileSystem newLine];
                    count=0;
                }
                
                [thisClass enumerateInstanceVars:^(KTVariable *aVariable) {
                    
                    if (firstTile) {
                        [self.tileSystem pushCurPositionNewLineAndIndent];
                        firstTile = NO;
                    }
                    // header tile if first of this tyle
                    if (count ==0) {
                        KETile *headerTitle = [self.tileSystem newHeaderTile];
                        headerTitle.display = @"Class Methods";
                        [methodTiles addObject:headerTitle];
                    }

                    KETile *methodTile = [self.tileSystem newTile];
                    [methodTiles addObject:methodTile];
                    methodTile.display = [self prettyString:aVariable.name];
                    methodTile.dataObject = aVariable;
                    [methodTile blockWhenClicked:^(KTClass *thisClass, KETile *tileThatWasClicked) {
                        // remove method tiles
                        [self removeAndPopFrom:methodTiles];
                        
                    }];
                    count++;
                }];
                
            }];
        }];
    }];
    
    
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

-(void)removeAndPopFrom:(NSMutableArray*) tileArray{
    if (tileArray.count) {
        [tileArray enumerateObjectsUsingBlock:^(KETile *tileToRemove, NSUInteger idx, BOOL *stop) {
            [tileToRemove dismiss];
        }];
        [tileArray removeAllObjects];
    }
    [self.tileSystem popPosition];
    [self.tileSystem popIndent];
}

-(void)test1{

   // NSArray *fred = class_copyMethodList(UIView class,)
    
	// Do any additional setup after loading the view.
    
    // test JavaScript
    JSContext *context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    context[@"a"] = @5;
    
    JSValue *aValue = context[@"a"];
    double a = [aValue toDouble];
    NSLog(@"%.0f", a);
    
    [context evaluateScript:@"a = 10"];
    JSValue *newAValue = context[@"a"];
    NSLog(@"%.0f", [newAValue toDouble]);
    
    [context evaluateScript:@"var square = function(x) {return x*x;}"];
    JSValue *squareFunction = context[@"square"];
    NSLog(@"%@", squareFunction);
    JSValue *aSquared = [squareFunction callWithArguments:@[context[@"a"]]];
    NSLog(@"a^2: %@", aSquared);
    JSValue *nineSquared = [squareFunction callWithArguments:@[@9]];
    NSLog(@"9^2: %@", nineSquared);
    
    //NSLog(@"%@", context[@"3 * 4 /3 + 2* square(3)"]);
    NSLog(@"%@", context[@"square(3);"]);
    
    context[@"factorial"] = ^(int x) {
        int factorial = 1;
        for (; x > 1; x--) {
            factorial *= x;
        }
        return factorial;
    };
    [context evaluateScript:@"var fiveFactorial = factorial(5);"];
    JSValue *fiveFactorial = context[@"fiveFactorial"];
    NSLog(@"5! = %@", fiveFactorial);
    
    JSRnD *thing = [[JSRnD alloc] init];
    thing.name = @"Alfred";
    thing.number = 3;
    context[@"thing"] = thing;
    JSValue *thingValue = context[@"thing"];
    
    NSLog(@"Thing: %@", thing);
    NSLog(@"Thing JSValue: %@", thingValue);
    
    thing.name = @"Betty";
    thing.number = 8;
    
    NSLog(@"Thing: %@", thing);
    NSLog(@"Thing JSValue: %@", thingValue);
    
    [context evaluateScript:@"thing.name = \"Carlos\"; thing.number = 5"];
    
    NSLog(@"Thing: %@", thing);
    NSLog(@"Thing JSValue: %@", thingValue);

/*
    // init the test kibbles
    self.hello = [Kibble createNewKibbleInstanceContaining:@[@2.5, @"cats", @"and", @24.1, @"dogs"]];
    self.hello.content = @{@1:@"red",@2:@"green",@3:@"blue"};
    self.hello.content = @{@"red":@"iscolor",@"green":@"iscolor",@"blue":@"iscolor"};
    //self.testNumber = [Kibble createNewKibbleInstanceContaining:[NSNumber numberWithFloat:7.32]];
    //self.testNumber.content = [NSDecimalNumber numberWithFloat:2.333];
    //self.testNumber.content = @2.333f;
*/
    
    self.testKibble = [[KibbleV2 alloc]init];
    
    self.square = [VMTalk createNewKibbleInstanceWithName:@"square"];
    //[self.square addTalkToParamater:@"x" paramaterName:nil andDescription:nil];
    [self.square addPhaseWith:[VMTalkPhase phaseWithParamater:@"x"]];
    [self.square setKibbleKode:@"x * x"];
    NSLog(@"square = %@", [self.square resultForTheseParamaters:@[@3]]);
    
    [self.testKibble.myKibbles addObject:self.square];
    
    
    self.multiply = [VMTalk createNewKibbleInstanceWithName:@"multiply"];
    [self.multiply addPhaseWith:[VMTalkPhase phaseWithParamater:@"x" ofType:[NSNumber numberWithFloat:0.1]]];
    [self.multiply addPhaseWith:[VMTalkPhase phaseWithParamater:@"y" ofType:[NSNumber class] withName:@"by"]];
    [self.multiply setKibbleKode:@"x * y"];
    
    [self.testKibble.myKibbles addObject:self.multiply];

    
    NSLog(@"multiply = %@", [self.multiply resultForTheseParamaters:@[@3, @"5 * 5"]]);
    NSLog(@"multiply = %@", [self.multiply resultForTheseParamaters:@[@3, @"square(7)"]]);
    NSLog(@"multiply = %@", [self.multiply resultForTheseParamaters:@[@3, @"5 * 5"]]);
    
    [self.multiply enumeratePhases:^(VMTalkPhase *thisTalkPhaseData) {
        NSString *debug = @"";
        if (thisTalkPhaseData.name) debug = [NSString stringWithFormat:@"%@%@ ", debug, thisTalkPhaseData.name];
        if (thisTalkPhaseData.paramater) debug = [NSString stringWithFormat:@"%@%@ ", debug, thisTalkPhaseData.paramater];
        if (thisTalkPhaseData.description) debug = [NSString stringWithFormat:@"%@%@ ", debug, thisTalkPhaseData.description];
        NSLog(@"%@", debug);
    }];
     
    
    NSMutableArray *parms = [[NSMutableArray alloc]init];
    while ([self.multiply isNextPhaseForTheseParamaters:parms]) {
        [self.multiply ifNextPhaseForTheseParamaters:parms findPhaseData:^(VMTalkPhase *thisTalkPhaseData) {
            NSUInteger rand = arc4random_uniform(25)+25;
            [parms addObject:[NSNumber numberWithUnsignedInteger:rand]];
        }];
    }
    NSLog(@"multiply %@ = %@", parms, [self.multiply resultForTheseParamaters:parms]);
    
    
    self.testObject = [VMKode createNewKibbleInstance];
    [self.testObject setKibbleKodeAsNativeVMScript:@"square(7) * multiply (1,2)"];
    self.testObject.name = @"Sarah";
    NSLog(@"testObject = %@", self.testObject.result);
    [self.testKibble.myKibbles addObject:self.testObject];

  
    [KETileSystem defaultTileSystem].parentView = self.view;
    
    self.tileSystem = [KETileSystem tileSystemWithSquareTileSize:128.0 parentView:self.view];
    [self.tileSystem editKibble:self.testKibble];
    
    KETile *newTile = [self.tileSystem newTile];
    newTile.display = self.testObject.result;
    newTile.dataObject = self.testObject;
    [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
                     NSLog(@"%@ wasClicked", dataObject);
                 }];

    NSString* longString = @"Goodbye crewl world - it is with great regreat that I find myself typing such a long line of text. But it is with great pleasue that I see that system seams to handle it";
    __block NSUInteger idx = 0;
    newTile = [self.tileSystem newTile];
    newTile.display = longString;
    newTile.dataObject = self.testObject;
    [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
        NSLog(@"%@ wasClicked", dataObject);
        idx++;
        if (idx>= longString.length) {
            idx = 1;
        }
        newTile.display = [longString substringToIndex:idx];
        
    }];

    
    newTile = [self.tileSystem newTile];
    newTile.display = self.square.name;
    newTile.dataObject = self.square;
    [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
        NSLog(@"%@ wasClicked", dataObject);
    }];
    
    newTile = [self.tileSystem newTile];
    newTile.display = self.multiply.name;
    newTile.dataObject = self.multiply;
    [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
        NSLog(@"%@ wasClicked", dataObject);
    }];
    
    newTile = [self.tileSystem newTile];
    newTile.display = self.square;
    newTile.dataObject = self.square;
    [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
        NSLog(@"%@ wasClicked", dataObject);
    }];

    newTile = [self.tileSystem newTile];
    newTile.display = self.multiply;
    newTile.dataObject = self.multiply;
    [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
        NSLog(@"%@ wasClicked", dataObject);
    }];
    
    [self.tileSystem addWhatNextTile];
    
    [KTClassRnD test];
}






@end
