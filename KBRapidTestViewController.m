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

@interface KBRapidTestViewController ()
@property (nonatomic, strong) Kibble *hello;
@property (nonatomic, strong) KibbleTalk *testNumber;
@property (nonatomic, strong) KibbleTalk *square;
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
    
    // init the test kibbles
    self.hello = [Kibble createNewKibbleInstanceContaining:@[@2.5, @"cats", @"and", @24.1, @"dogs"]];
    self.hello.content = @{@1:@"red",@2:@"green",@3:@"blue"};
    self.hello.content = @{@"red":@"iscolor",@"green":@"iscolor",@"blue":@"iscolor"};
    //self.testNumber = [Kibble createNewKibbleInstanceContaining:[NSNumber numberWithFloat:7.32]];
    //self.testNumber.content = [NSDecimalNumber numberWithFloat:2.333];
    //self.testNumber.content = @2.333f;
    
    
    self.square = [KibbleTalk createNewKibbleInstanceWithName:@"square"];
    [self.square addKibbleTalkParamater:@5 withSyntax:@"x" andDescription:nil];
    [self.square addKibbleKode:@"x"];
    [self.square addKibbleKode:@"*"];
    [self.square addKibbleKode:@"x"];
    NSLog(@"%@",self.square.result);

    // display the test kibbles
    (void)[[KBEditorKibbleViewContoller alloc]initForThisKibble:self.square
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
