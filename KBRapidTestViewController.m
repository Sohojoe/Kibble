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

@interface KBRapidTestViewController ()
@property (nonatomic, strong) Kibble *hello;
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
    KibbleType *helloKibbleType = [[KBDatabase aDatabase] kibbleTypeElseLazyInitForKey:@"hello"];
    
    self.hello = [[Kibble alloc]init:helloKibbleType
                                  at:CGPointMake(200, 200)
                               after:0.0
                       addToParentVC:self
                            maxWidth:0.0
                    blockWhenClicked:^(Kibble *thisKibble) {
                        NSLog(@"wasClicked");
                    }];
}



@end
