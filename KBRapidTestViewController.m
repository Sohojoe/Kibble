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

#import "KTClassRnD.h"

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

  
    [KETileSystem defaultTileSystem].parentViewController = self;
    
    self.tileSystem = [KETileSystem tileSystemWithSquareTileSize:128.0 parentVC:self];
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
