//
//  Narrator.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/15/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import "Narrator.h"
#import "Speak.h"

//#define DEBUG_STRINGS


@interface Narrator()
@property (nonatomic, strong) NSDictionary* images;
@property (nonatomic) CGPoint internalPos;
@property (nonatomic) float maxWidth;
@property (nonatomic, strong) NSString* animSequence;
@property (nonatomic) unsigned int animID;
@end

@implementation Narrator

+(Narrator*)sharedNarrator{
    static Narrator *shared = nil;
    
    if (shared==nil) {
        // first Time Init
        shared = [[super allocWithZone:NULL] init];
    }
    return shared;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(NSDictionary*)sampleAnimation{
    NSMutableDictionary *anims = [[NSMutableDictionary alloc]init];
    
    [anims setObject:[UIImage imageNamed:@"maleStand"] forKey:@"stand"];
    [anims setObject:[UIImage imageNamed:@"maleStandBlink"] forKey:@"blink"];
    [anims setObject:[UIImage imageNamed:@"maleStandTalk1"] forKey:@"talk1"];

    return anims;
}

-(void)setSequence:(NSString*)seq{
    self.animSequence = seq;
    
    if([seq caseInsensitiveCompare:@"wait"] == NSOrderedSame) {
        // wait sequence
#ifdef DEBUG_STRINGS
        NSLog(@"%@",seq);
#endif
        [self setImage:@"stand"];
        float delay = (arc4random()%RAND_MAX)/(RAND_MAX*1.0);
        unsigned int myID = ++ self.animID;
        delay *= 5.0;
        delay += 0.5;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if(myID == self.animID) {
                [self setImage:@"blink"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.125 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    if(myID == self.animID) {
                        [self setSequence:self.animSequence];
                    }
                });

            }
		});
    } else if([seq caseInsensitiveCompare:@"talk"] == NSOrderedSame) {
        // talk sequence
#ifdef DEBUG_STRINGS
        NSLog(@"%@",seq);
#endif
        [self setImage:@"talk1"];
        float delay = (arc4random()%RAND_MAX)/(RAND_MAX*1.0);
        unsigned int myID = ++ self.animID;
        delay *= 0.6;
        delay += 0.1;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if(myID == self.animID) {
                [self setImage:@"stand"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    if(myID == self.animID) {
                        [self setSequence:self.animSequence];
                    }
                });
                
            }
		});
    }
    
}

-(UIImage*)setImage:(NSString*)imageID{
    UIImage *image = [self.images objectForKey:imageID];

    [self setImage:image forState:UIControlStateNormal];

    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    if (bounds.size.width >self.maxWidth) {
        float rescale = self.maxWidth/bounds.size.width;
        bounds.size.width *= rescale;
        bounds.size.height *= rescale;
    }
    bounds.origin.x = (bounds.size.width/2);
    bounds.origin.y = (bounds.size.height/2);
    self.bounds = bounds;

    //CGRect frame = self.frame;
    //frame.origin.x = self.internalPos.x-(frame.size.width/2);
    //frame.origin.y = self.internalPos.y-(frame.size.height/2);
    //self.frame = frame;
    

    return image;
}

//-(Narrator*)initAt:(CGPoint)internalPos after:(float)delay with:(NSDictionary*)theseImages{
-(void)initAt:(CGPoint)newPos after:(float)delay{

    // init object
    self.images = [self sampleAnimation];
    self.internalPos = newPos;
    self.maxWidth = 256;
    
    
    self.hidden = NO;
    
    [self setAutoresizingMask:
     UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleBottomMargin |
     UIViewAutoresizingFlexibleTopMargin];
    
    [self setSequence:@"wait"];
    //[self setSequence:@"talk"];

    CGRect frame = self.frame;
    frame.origin.x = self.internalPos.x-(frame.size.width/2);
    frame.origin.y = self.internalPos.y-(frame.size.height/2);
    self.frame = frame;

    
    if (delay) {
        [self appearAnimation:delay];
    }
    
}

-(void)appearAnimation:(float)delay{
    // options
    static UIViewAnimationOptions opt = 0
    //+ UIViewAnimationOptionAllowUserInteraction
    //+ UIViewAnimationOptionBeginFromCurrentState
    //+ UIViewAnimationOptionOverrideInheritedDuration
    //+ UIViewAnimationOptionRepeat
    //+ UIViewAnimationOptionAutoreverse
    + UIViewAnimationOptionCurveLinear
    //+ UIViewAnimationOptionCurveEaseInOut
    //+ UIViewAnimationOptionCurveEaseIn
    //+ UIViewAnimationOptionCurveEaseOut
    +0;
    
    // start state
    self.alpha = 0.0;
    
    
    [UIView animateWithDuration:1.33 delay:delay options:opt
                     animations:
     ^{
         // target state
         self.alpha = 1.0;
         //CGAffineTransform t = fx.transform;
         ////t = CGAffineTransformMakeRotation(16);
         //t = CGAffineTransformScale(t, endScaleX, endScaleY);
         //fx.transform = t;
     }
                     completion:nil
     ];
}

-(void)moveTo:(CGPoint)newPos isAnimated:(BOOL)isAnimated{
    self.internalPos = newPos;
    CGRect frame = self.frame;
    frame.origin.x = self.internalPos.x-(frame.size.width/2);
    frame.origin.y = self.internalPos.y-(frame.size.height/2);

    if (isAnimated) {
        static UIViewAnimationOptions opt =
        UIViewAnimationOptionCurveEaseOut
        | UIViewAnimationOptionBeginFromCurrentState
        | UIViewAnimationOptionAllowUserInteraction
        | UIViewAnimationOptionOverrideInheritedDuration;
        

        
        [UIView animateWithDuration:0.33 delay:0.0 options:opt
                         animations:
         ^{
             self.frame = frame;
         }
                         completion:nil
         ];
        
    } else {
        self.frame = frame;
    }
    
}

-(void)say:(id)words{
    [self say:words completionBlock:nil];
}
-(void)say:(id)words completionBlock:(void (^)(BOOL success))completionBlock{
    [self say:words startSpeakingBlock:nil completionBlock:completionBlock];
}
-(void)say:(id)words startSpeakingBlock:(void (^)(void))startSpeakingBlock completionBlock:(void (^)(BOOL success))completionBlock{
    
#ifdef DEBUG_STRINGS
    NSLog(@"say:%@",words);
#endif
    
    [[Speak sharedSpeak]say:words
         startSpeakingBlock:^{
             // stated
#ifdef DEBUG_STRINGS
             NSLog(@"startSpeach:'%@'", words);
#endif
             [self setSequence:@"talk"];
             if(startSpeakingBlock)startSpeakingBlock();
             
         } completionBlock:^(BOOL success) {
             // finished
             [self setSequence:@"wait"];
             if (completionBlock) completionBlock(success);
         }];
}
-(void)stop{
    [[Speak sharedSpeak]stop];
    [self setSequence:@"wait"];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseEnded) {
            // if touch is still within bounds
            UITouch *touch = [[event allTouches] anyObject];
            CGPoint location = [touch locationInView:self];
            if (CGRectContainsPoint([self bounds], location)) {
                //was pressed
                [[NSNotificationCenter defaultCenter] postNotificationName:@"repeatPrompt" object:nil];
            }
        }
    }
    [super touchesEnded:touches withEvent:event];
}

@end
