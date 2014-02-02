//
//  SCElementViewController.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/9/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import "SCElementViewController.h"
#import "Narrator.h"
#import "SoundBank.h"

@interface SCElementViewController()
@property (nonatomic, strong) UIView *parentView;
-(void)startTapInput;
-(void)wasTapped;
@property (nonatomic, strong) void (^ callWhenClickedBlock) (SCElementViewController*);
@end


//--------------------------------------------------------------------------
@implementation SCElementViewController
@synthesize position;

-(SCElementViewController*)init:(SCElement*)thisElement at:(CGPoint)pos after:(float)delay  addToParentView:(UIView*)view blockWhenClicked:(void (^)(SCElementViewController* thisElement))wasClickedBlock{
    
    
    float maxWidth = 100000000;
    
    if (thisElement.image) {
        // use the image for the element
        self = ([self initWithImage:thisElement at:pos after:delay maxWidth:maxWidth addToTest:view]);
    } else {
        // use the name to create text
        self = ([self initWithText:thisElement at:pos after:delay maxWidth:maxWidth addToTest:view]);
    }
    
    self.callWhenClickedBlock = wasClickedBlock;
    
    return self;

}



-(SCElementViewController*)init:(SCElement*)thisElement at:(CGPoint)pos after:(float)delay maxWidth:(float)maxWidth addToTest:(UIView*)view{
    
    if (thisElement.image) {
        // use the image for the element
        return ([self initWithImage:thisElement at:pos after:delay maxWidth:maxWidth addToTest:view]);
    } else {
        // use the name to create text
        return ([self initWithText:thisElement at:pos after:delay maxWidth:maxWidth addToTest:view]);
    }
}

-(SCElementViewController*)initWithText:(SCElement*)thisElement at:(CGPoint)pos after:(float)delay maxWidth:(float)maxWidth addToTest:(UIView*)view{
    
    // init object
    CGRect frame = CGRectMake(0, 0, 512, 512);
    self = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    if (self == nil) return self; // early exit on error
    
    self.element = thisElement;
    self.parentView = view;
    
    BOOL mutiLine;
    NSString *lowerName = [thisElement.name lowercaseString];
    if ([lowerName rangeOfString:@"\n"].location == NSNotFound) {
        mutiLine = NO;
    } else {
        mutiLine = YES;
    }
    
    // greed = 55,168,74
    
    //UIColor *color = [UIColor colorWithRed:0.62745 green:0.6 blue:0.59375 alpha:1.0];
    //UIColor *selectedColor = [UIColor colorWithRed:0.62745*0.5 green:0.6*0.5 blue:0.59375*0.5 alpha:1.0];
    // blue from blue square
    UIColor *color = [UIColor colorWithRed:(72.0/255.0) green:(118.0/255.0) blue:(150.0/255.0) alpha:1.0];
    //UIColor *selectedColor = [UIColor colorWithRed:(254.0/255.0)*.95 green:(223.0/255.0)*.95 blue:(116.0/255.0)*.95 alpha:1.0];
    UIColor *selectedColor = [UIColor colorWithRed:(145.0/255.0) green:(184.0/255.0) blue:(214.0/255.0) alpha:1.0];
    //UIColor *selectedColor = [UIColor colorWithRed:(150.0/255.0) green:(72.0/255.0) blue:(78.0/255.0) alpha:1.0];
    //UIColor *selectedColor = [UIColor colorWithRed:(128.0/255.0) green:(54.0/255.0) blue:(19.0/255.0) alpha:1.0];
    //UIColor *selectedColor = [UIColor colorWithRed:(55.0/255.0) green:(168.0/255.0) blue:(74.0/255.0) alpha:1.0];
    //UIColor *selectedColor = [UIColor colorWithRed:(197.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:1.0];
    // dark blue from logo
    //UIColor *color = [UIColor colorWithRed:(0.0/255.0) green:(137.0/255.0) blue:(195.0/255.0) alpha:1.0];
    //UIColor *selectedColor = [UIColor colorWithRed:(0.0/255.0)*.5 green:(137.0/255.0)*.5 blue:(195.0/255.0)*.5 alpha:1.0];
    // light blue from logo
    //UIColor *color = [UIColor colorWithRed:(45.0/255.0) green:(180.0/255.0) blue:(255.0/255.0) alpha:1.0];
    //UIColor *selectedColor = [UIColor colorWithRed:(0.0/255.0)*1.0 green:(137.0/255.0)*1.0 blue:(195.0/255.0)*1.0 alpha:1.0];

    
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:selectedColor forState:UIControlStateSelected];
    [self setTitleColor:selectedColor forState:UIControlStateHighlighted];
    [self setTitleShadowColor:[UIColor colorWithRed:0.62745*0.25 green:0.6*0.25 blue:0.59375*0.25 alpha:1.0] forState:UIControlStateNormal];
    [self setTitle:thisElement.name forState:UIControlStateNormal];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    if (mutiLine) {
        [self.titleLabel setFont:[UIFont fontWithName:@"Arial" size:64.0f]];
        self.titleLabel.numberOfLines = 0;
    } else {
        CGFloat fontSize = 128.0f;
        if (thisElement.name.length ==2) {
            fontSize = 96.0f;
        } else if (thisElement.name.length >=3) {
            fontSize = 64.0f;
        }
        
        [self.titleLabel setFont:[UIFont fontWithName:@"Arial" size:fontSize]];
    }
    // add text effect
/*
//    NSMutableAttributedString  *attStr = [[NSMutableAttributedString alloc]initWithAttributedString:[self attributedTitleForState:UIControlStateNormal]];
    NSAttributedString *s = [self.titleLabel attributedText];
    NSMutableAttributedString  *attStr = [[NSMutableAttributedString alloc]initWithAttributedString:s];
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[attStr attributesAtIndex:0 effectiveRange:nil]];
    [attrs setObject:NSTextEffectLetterpressStyle forKey:NSTextEffectAttributeName];
    [attStr setAttributes:attrs range:NSMakeRange(0, attStr.length)];
    [self setAttributedTitle:attStr forState:UIControlStateNormal];
    attrs = [[NSMutableDictionary alloc] initWithDictionary:attrs copyItems:YES];
    [attrs removeObjectForKey:NSForegroundColorAttributeName];
    [attrs setObject:[UIColor colorWithRed:0.62745*0.5 green:0.6*0.5 blue:0.59375*0.5 alpha:1.0] forKey:NSForegroundColorAttributeName];
    [attStr setAttributes:attrs range:NSMakeRange(0, attStr.length)];
    [self setAttributedTitle:attStr forState:UIControlStateSelected];
    [self setAttributedTitle:attStr forState:UIControlStateHighlighted];
*/
    

    if (frame.size.width >maxWidth) {
        float rescale = maxWidth/frame.size.width;
        frame.size.width *= rescale;
        frame.size.height *= rescale;
    }
    frame.origin.x = pos.x - (frame.size.width/2);
    frame.origin.y = pos.y - (frame.size.height/2);
    self.frame = frame;
    self.hidden = NO;
    
    [self setAutoresizingMask:
     UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleBottomMargin |
     UIViewAutoresizingFlexibleTopMargin];
    
    [view addSubview:self];
    
    if (delay) {
        [self appearAnimation:delay];
    }
    
    return self;
}


-(SCElementViewController*)initWithImage:(SCElement*)thisElement at:(CGPoint)pos after:(float)delay maxWidth:(float)maxWidth addToTest:(UIView *)view{

    // init object
    UIImage *image = thisElement.image;
    self = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    if (self == nil) return self; // early exit on error

    self.element = thisElement;
    self.parentView = view;

    [self setImage:image forState:UIControlStateNormal];
    CGRect frame = self.frame;
    if (frame.size.width >maxWidth) {
        float rescale = maxWidth/frame.size.width;
        frame.size.width *= rescale;
        frame.size.height *= rescale;
    }
    frame.origin.x = pos.x - (frame.size.width/2);
    frame.origin.y = pos.y - (frame.size.height/2);
    self.frame = frame;
    self.hidden = NO;
    
    [self setAutoresizingMask:
     UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleBottomMargin |
     UIViewAutoresizingFlexibleTopMargin];
    
    [view addSubview:self];
    
    if (delay) {
        [self appearAnimation:delay];
    }
    
    return self;
}

-(CGPoint)position{
    CGPoint centerPosition = self.frame.origin;
    centerPosition.x += (self.frame.size.width/2);
    centerPosition.y += (self.frame.size.height/2);
    return centerPosition;
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

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseEnded) {
            // if touch is still within bounds
            UITouch *touch = [[event allTouches] anyObject];
            CGPoint location = [touch locationInView:self];
            if (CGRectContainsPoint([self bounds], location)) {
                [self wasTapped];
            }
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseBegan) {
            self.highlighted = YES;
            [self startTapInput];
        }
    }
}


-(void)startTapInput{
}
-(void)wasTapped{
    //[[Narrator sharedNarrator] stop];
    //[[Narrator sharedNarrator] say:[[SoundBank activeSoundBank] audioElementFor:self.element]];
    if (self.callWhenClickedBlock) self.callWhenClickedBlock(self);
}
-(void)dismiss{
    // options
    static UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseIn;
    
    float speed = 0.75;
    
    // start state
    CGRect targetFrame = self.frame;
    targetFrame.origin.y += self.superview.bounds.size.height * .05;
    
    float center = self.superview.bounds.size.width/2;
    float offset = targetFrame.origin.x;
    offset += targetFrame.size.width/2;
    offset -= self.superview.bounds.size.width/2;
    float speedOffset = offset / (self.superview.bounds.size.width/2);
    offset *= 0.125;
    targetFrame.origin.x = center + offset - targetFrame.size.width/2;
    
    center = self.superview.bounds.size.height/2;
    offset = targetFrame.origin.y;
    offset += targetFrame.size.height/2;
    offset -= self.superview.bounds.size.height/2;
    offset *= 0.125;
    targetFrame.origin.y = center + offset - targetFrame.size.height/2;

    if (speedOffset <0) speedOffset = 0-speedOffset;
    speed -= (0.05 * speedOffset);

    
    [UIView animateWithDuration:speed delay:0.0 options:opt
                     animations:
     ^{
         // target state
         self.frame = targetFrame;
         self.alpha = 0.0;
         //self.transform = CGAffineTransformMakeScale(0.2, 0.2);
         CGAffineTransform t1 = CGAffineTransformMakeScale(0.2, 0.2);
         float angle = (arc4random()%RAND_MAX)/(RAND_MAX*1.0) * 90.0;
         angle -= 45.0;
         CGAffineTransform t2 = CGAffineTransformMakeRotation(((angle) / 180.0 * M_PI));
         self.transform =  CGAffineTransformConcat (t1, t2);
     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }
     ];

}

-(void)addPopAnimation{
    
    // options
    static UIViewAnimationOptions opt = UIViewAnimationOptionOverrideInheritedOptions | UIViewAnimationOptionCurveLinear;
    
    // start state
    CGRect startFrame = self.frame;
    CGRect targetFrame = self.frame;
    //startFrame.origin.x += self.superview.bounds.size.width;
    //startFrame.origin.y = self.view.bounds.size.height + buttonVC.superview.bounds.size.height;
    //startFrame.origin.y += startFrame.size.height/2;
    self.frame = startFrame;
    self.alpha = 0.0;
    
    [UIView animateWithDuration:0.15 delay:0.0 options:opt
                     animations:
     ^{
         // target state
         self.frame = targetFrame;
         self.alpha = 1.0;
     }
                     completion:nil
     ];
}

@end

//--------------------------------------------------------------------------
@implementation SCElementTargetViewController
-(void)startTapInput{
    [[AudioWrapper sharedAudio] playKeyClickDown];
}
-(void)wasTapped{
    [[AudioWrapper sharedAudio] playKeyClickUp];
    //NOT IMPLEMENTED YET [self.test targetPressed:self];
}

-(void)appearAnimation:(float)delay{
    // options
    static UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseOut;
    
    // start state
    CGRect startFrame = self.frame;
    CGRect targetFrame = self.frame;
    //startFrame.origin.x += self.superview.bounds.size.width;
    startFrame.origin.y += self.superview.bounds.size.height;
    self.frame = startFrame;
    
    [UIView animateWithDuration:1.25 delay:delay options:opt
                     animations:
     ^{
         // target state
         self.frame = targetFrame;
     }
                     completion:nil
     ];
}
@end

//--------------------------------------------------------------------------
@implementation SCElementPromptViewController

-(void)wasTapped{
    //NOT IMPLEMENTED YET [self.test promptPressed:self];
}

-(void)appearAnimation:(float)delay{
    // options
    static UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseOut;
    
    // start state
    CGRect startFrame = self.frame;
    CGRect targetFrame = self.frame;
    //startFrame.origin.y += self.superview.bounds.size.height;
    startFrame.origin.x += self.superview.bounds.size.width;
    self.frame = startFrame;
    
    [UIView animateWithDuration:1.25 delay:delay options:opt
                     animations:
     ^{
         // target state
         self.frame = targetFrame;
     }
                     completion:nil
     ];
}

@end

//--------------------------------------------------------------------------
@interface SCElementSpeakerViewController ()
@end
@implementation SCElementSpeakerViewController

-(void)wasTapped{
    //NOT IMPLEMENTED YET [self.test speakerPressed:self];
}
@end
