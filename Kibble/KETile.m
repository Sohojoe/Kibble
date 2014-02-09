//
//  KETile.m
//  Kibble
//
//  Created by Joe on 2/8/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KETile.h"
#import "KETileSystem.h"


@interface KETile ()
@property (nonatomic, strong) UIViewController *parentViewController;
-(void)startTapInput;
-(void)wasTapped;
@property (nonatomic, strong) void (^ callWhenClickedBlock) (id, KETile*);
@property (nonatomic, strong) UILabel *ourTitleLable;
@end

@implementation KETile
@synthesize display;
@synthesize selected;

-(void)blockWhenClicked:(void (^)(id dataObject, KETile* tileThatWasClicked))wasClickedBlock{
    self.callWhenClickedBlock = wasClickedBlock;
}

-(id)display{
    return display;
}
-(void)setDisplay:(id)displayThis{
    if ([displayThis isKindOfClass:([UIImage class])]) {
        // it's an image
        [self setDisplayWithImage:displayThis];
    } else {
        // display as string
        [self setDisplayWithString:displayThis];
    }
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    }
    return self;
}


//----------------------------------------------
-(void)removeOurTextLabel{
    if (self.ourTitleLable) {
        [self.ourTitleLable removeFromSuperview];
        self.ourTitleLable = nil;
    }
}

-(void)setDisplayWithString:(NSString*)thisString{
    if ([thisString class] != [NSString class]) {
        //make a string of it
        thisString = [NSString stringWithFormat:@"%@",thisString];
    }
    [self removeOurTextLabel];
    
    BOOL mutiLine;
    NSString *lowerName = [thisString lowercaseString];
    if ([lowerName rangeOfString:@"\n"].location == NSNotFound) {
        mutiLine = NO;
    } else {
        mutiLine = YES;
    }
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    //frame.size.width *=0.5;
    //frame.size.height *=0.5;
    self.ourTitleLable = [[UILabel alloc] initWithFrame:frame];
    
    UIColor *color = [UIColor colorWithRed:(72.0/255.0) green:(118.0/255.0) blue:(150.0/255.0) alpha:1.0];
    UIColor *selectedColor = [UIColor colorWithRed:(145.0/255.0) green:(184.0/255.0) blue:(214.0/255.0) alpha:1.0];
    
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:selectedColor forState:UIControlStateSelected];
    [self setTitleColor:selectedColor forState:UIControlStateHighlighted];
    [self setTitleShadowColor:[UIColor colorWithRed:0.62745*0.25 green:0.6*0.25 blue:0.59375*0.25 alpha:1.0] forState:UIControlStateNormal];
    //[self setTitle:thisString forState:UIControlStateNormal];
    
    
    //self.ourTitleLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, frame.size.width-100, 100)];
    //self.ourTitleLable.font = [UIFont boldSystemFontOfSize:24.0];
    self.ourTitleLable.textColor = color;
    self.ourTitleLable.highlightedTextColor = selectedColor;
    //self.ourTitleLable.highlighted = YES;
    self.ourTitleLable.text = thisString;
    //self.ourTitleLable.lineBreakMode = NSLineBreakByTruncatingTail;
    
    self.ourTitleLable.adjustsFontSizeToFitWidth = YES;
    self.ourTitleLable.minimumScaleFactor = 0.1;
    self.ourTitleLable.textAlignment = NSTextAlignmentCenter;
    float fontScale = self.frame.size.width;

    if (mutiLine) {
        self.ourTitleLable.numberOfLines = 0;
        [self.ourTitleLable setFont:[UIFont fontWithName:@"Arial" size:fontScale/6]];
    } else {
        // figure out ideal chars per line based on scaling
        NSUInteger charsPerLine = self.frame.size.width / 8;
        
        if (self.ourTitleLable.text.length <charsPerLine) {
            // single line
            self.ourTitleLable.numberOfLines = 1;
            // in center, wrap at words
            self.ourTitleLable.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
            //self.ourTitleLable.lineBreakMode = NSLineBreakByWordWrapping;
        } else {
            // split to multiple lines
            self.ourTitleLable.numberOfLines = (self.ourTitleLable.text.length / charsPerLine)+1;
            // in center
            self.ourTitleLable.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        }
        
        float fontSize = fontScale * 1.0;
/*        if (self.ourTitleLable.text.length ==2 ) {
            fontSize = fontScale * 0.85;
        } else if (self.ourTitleLable.text.length ==3 ) {
            fontSize = fontScale * 0.75;
        } else if (self.ourTitleLable.text.length ==4 ) {
            fontSize = fontScale * 0.6;
        } else if (self.ourTitleLable.text.length >=5 ) {
            fontSize = fontScale /6;
        }
*/        [self.ourTitleLable setFont:[UIFont fontWithName:@"Arial" size:fontSize]];
    }
    [self addSubview:self.ourTitleLable];
    //[self sizeToFit];
    
    // set position
    frame = self.frame;
    frame.origin.x = self.position.x - (frame.size.width/2);
    frame.origin.y = self.position.y - (frame.size.height/2);
    self.frame = frame;
    self.hidden = NO;
    
    // handle rotation and constraints
    
/*    [self setAutoresizingMask:
     UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleBottomMargin |
     UIViewAutoresizingFlexibleTopMargin];
*/
    
    [self.parentViewController.view addSubview:self];
}
-(void)setDisplayWithImage:(UIImage*)thisImage{

    [self removeOurTextLabel];

    CGRect oldFrame = self.frame;

    
    [self setImage:thisImage forState:UIControlStateNormal];
    CGRect frame = self.frame;
    if (frame.size.width >oldFrame.size.width) {
        float rescale = oldFrame.size.width/frame.size.width;
        frame.size.width *= rescale;
        frame.size.height *= rescale;
    }
    frame.origin.x = self.position.x - (frame.size.width/2);
    frame.origin.y = self.position.y - (frame.size.height/2);
    self.frame = frame;
    self.hidden = NO;
    
/*    [self setAutoresizingMask:
     UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleBottomMargin |
     UIViewAutoresizingFlexibleTopMargin];
*/
    [self.parentViewController.view addSubview:self];
}

// overide position to handle the center
-(CGPoint)position{
    CGPoint centerPosition = self.frame.origin;
    centerPosition.x += (self.frame.size.width/2);
    centerPosition.y += (self.frame.size.height/2);
    return centerPosition;
}
-(void)setPosition:(CGPoint)centerPosition{
    CGRect frame = self.frame;
    frame.origin = centerPosition;
    frame.origin.x -= (self.frame.size.width/2);
    frame.origin.y -= (self.frame.size.height/2);
    self.frame = frame;
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


// handle our label for highlighting
-(void)setHighlighted:(BOOL)newHighlightedState{
    [super setHighlighted:newHighlightedState];
    
    self.ourTitleLable.highlighted  = newHighlightedState;
    
}


//----------------------------------------------------------------------
//-- inputs

-(void)startTapInput{
}
-(void)wasTapped{
    //[[Narrator sharedNarrator] stop];
    //[[Narrator sharedNarrator] say:[[SoundBank activeSoundBank] audioElementFor:self.element]];
    if (self.callWhenClickedBlock) self.callWhenClickedBlock(self.dataObject, self);
}


//----------------------------------------------------------------------
//-- dismiss tile
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

//----------------------------------------------------------------------
//-- animations

-(void)addAppearAnimation:(float)delay{
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
    
}-(void)addPopAnimation{
    
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
