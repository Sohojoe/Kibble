//
//  KBRapidTestViewController.m
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KBRapidTestViewController.h"
#import "KBDatabase.h"
#import "Kibble.h"
#import "KBEditorKibbleViewContoller.h"
#import "KibbleTalk.h"
//@import JavaScriptCore;
#import "JSRnD.h"
#import "KibbleVM.h"

@interface KBRapidTestViewController ()
@property (nonatomic, strong) Kibble *hello;
@property (nonatomic, strong) KibbleTalk *testNumber;
@property (nonatomic, strong) KibbleTalk *oldSquare;

@property (nonatomic, strong) KibbleVMTalk *square;
@property (nonatomic, strong) KibbleVMTalk *multiply;

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
    
    // init the test kibbles
    self.hello = [Kibble createNewKibbleInstanceContaining:@[@2.5, @"cats", @"and", @24.1, @"dogs"]];
    self.hello.content = @{@1:@"red",@2:@"green",@3:@"blue"};
    self.hello.content = @{@"red":@"iscolor",@"green":@"iscolor",@"blue":@"iscolor"};
    //self.testNumber = [Kibble createNewKibbleInstanceContaining:[NSNumber numberWithFloat:7.32]];
    //self.testNumber.content = [NSDecimalNumber numberWithFloat:2.333];
    //self.testNumber.content = @2.333f;
    
    self.square = [KibbleVMTalk createNewKibbleInstanceWithName:@"square"];
    [self.square addTalkToParamater:@"x" paramaterName:nil andDescription:nil];
    [self.square addKibbleKode:@"x * x"];
    NSLog(@"square = %@", [self.square resultForTheseParamaters:@[@3]]);
    
    
    self.multiply = [KibbleVMTalk createNewKibbleInstanceWithName:@"multiply"];
    [self.multiply addTalkToParamater:@"x" paramaterName:nil andDescription:nil];
    [self.multiply addTalkToParamater:@"y" paramaterName:@"by" andDescription:nil];
    [self.multiply addKibbleKode:@"x * y"];
    
    NSLog(@"multiply = %@", [self.multiply resultForTheseParamaters:@[@3, @4]]);
    
    
    self.oldSquare = [KibbleTalk createNewKibbleInstanceWithName:@"oldSquare"];
    [self.oldSquare addKibbleTalkParamater:@5 withSyntax:@"x" andDescription:nil];
    [self.oldSquare addKibbleKode:@"x"];
    [self.oldSquare addKibbleKode:@"*"];
    [self.oldSquare addKibbleKode:@"x"];
    NSLog(@"%@",self.oldSquare.result);

    // display the test kibbles
    (void)[[KBEditorKibbleViewContoller alloc]initForThisKibble:self.oldSquare
                                                             at:CGPointMake(200, 200)
                                                          after:0.0
                                                  addToParentVC:self
                                                       maxWidth:256.0
                                               blockWhenClicked:^(Kibble *thisKibble) {
                                                   NSLog(@"wasClicked");
                                               }];

    self.testNumber = [KibbleTalk createNewKibbleInstance];
    //[self.testNumber addKibbleKode:@"27"];
    //[self.testNumber addKibbleKode:@"*"];
    //[self.testNumber addKibbleKode:@"3"];
    [self.testNumber addKibbleKode:self.square];
    [self.testNumber addKibbleKode:@"7"];
    NSLog(@"%@",self.testNumber.result);

    
    
    (void)[[KBEditorKibbleViewContoller alloc]initForThisKibble:self.testNumber
                                                   at:CGPointMake(400,400)
                                                after:0.4
                                        addToParentVC:self
                                             maxWidth:256.0
                                     blockWhenClicked:^(Kibble *thisKibble) {
                                         NSLog(@"numberClicked");
                                     }];
    
    //[KBNumberType debugPrintTypes];
}



@end
