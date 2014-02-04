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

@interface KBRapidTestViewController ()
@property (nonatomic, strong) Kibble *hello;
@property (nonatomic, strong) Kibble *testNumber;
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
    
    // init the test KibbleTypes
    KibbleType *baseKibbleType = [[KBDatabase aDatabase] kibbleTypeElseLazyInitForKey:[KibbleType class]];
    
    // init the test kibbles
    self.hello = [baseKibbleType createNewKibbleInstanceContaining:[NSArray arrayWithObjects:@"string",[NSNumber numberWithFloat:2.3], @"cat", nil]];
    self.testNumber = [baseKibbleType createNewKibbleInstanceContaining:[NSNumber numberWithFloat:7.32]];
    
    // display the test kibbles
    (void)[[KBEditorKibbleViewContoller alloc]initForThisKibble:self.hello
                                                       at:CGPointMake(200, 200)
                                                    after:0.0
                                            addToParentVC:self
                                                 maxWidth:0.0
                                         blockWhenClicked:^(Kibble *thisKibble) {
                                             NSLog(@"wasClicked");
                                         }];
    
    (void)[[KBEditorKibbleViewContoller alloc]initForThisKibble:self.testNumber
                                                   at:CGPointMake(400,400)
                                                after:0.4
                                        addToParentVC:self
                                             maxWidth:0.0
                                     blockWhenClicked:^(Kibble *thisKibble) {
                                         NSLog(@"numberClicked");
                                     }];
    
    //[KBNumberType debugPrintTypes];
}



@end
