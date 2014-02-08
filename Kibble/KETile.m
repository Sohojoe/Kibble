//
//  KETile.m
//  Kibble
//
//  Created by Joe on 2/8/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KETile.h"
@interface KETile ()
@property (nonatomic, strong) UIViewController *parentViewController;
-(void)startTapInput;
-(void)wasTapped;
@property (nonatomic, strong) void (^ callWhenClickedBlock) (id, KETile*);
@property (nonatomic, strong) id dataObject; // pass through object
@end

@implementation KETile

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(KETile*)tileWithImage:(UIImage*)thisImage
                     at:(CGPoint)pos
                  after:(float)delay
          addToParentVC:(UIViewController *)thisParentVC
             dataObject:(id)thisDataObject
               maxWidth:(float)maxWidth
       blockWhenClicked:(void (^)(id dataObject, KETile* tileThatWasClicked))wasClickedBlock{
    
    KETile* tile;
    tile = [[KETile alloc] initTileWithImage:thisImage
                                          at:pos
                                       after:delay
                               addToParentVC:thisParentVC
                                  dataObject:thisDataObject
                                    maxWidth:maxWidth
                            blockWhenClicked:wasClickedBlock];
    return tile;
}

+(KETile*)tileWithString:(NSString*)thisString
                      at:(CGPoint)pos
                   after:(float)delay
           addToParentVC:(UIViewController *)thisParentVC
              dataObject:(id)thisDataObject
                maxWidth:(float)maxWidth
        blockWhenClicked:(void (^)(id dataObject, KETile* tileThatWasClicked))wasClickedBlock{
    
    KETile* tile = nil;
    tile = [[KETile alloc] initTileWithString:thisString
                                           at:pos
                                        after:delay
                                addToParentVC:thisParentVC
                                   dataObject:thisDataObject
                                     maxWidth:maxWidth
                             blockWhenClicked:wasClickedBlock];
    return tile;
}

-(KETile*)initTileWithString:(NSString*)thisString
                          at:(CGPoint)pos
                       after:(float)delay
               addToParentVC:(UIViewController *)thisParentVC
                  dataObject:(id)thisDataObject
                    maxWidth:(float)maxWidth
            blockWhenClicked:(void (^)(id dataObject, KETile* tileThatWasClicked))wasClickedBlock{

    
    // init object
    CGRect frame = CGRectMake(0, 0, 512, 512);
    self = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    if (self == nil) return self; // early exit on error

    self.dataObject = thisDataObject;
    
    if ([thisString class] != [NSString class]) {
        //make a string of it
        thisString = [NSString stringWithFormat:@"%@",thisString];
    }
    
    
    self.parentViewController = thisParentVC;
    
    if (maxWidth) {
        if (frame.size.width >maxWidth) {
            float rescale = maxWidth/frame.size.width;
            frame.size.width *= rescale;
            frame.size.height *= rescale;
        }
    }
    
    
    BOOL mutiLine;
    NSString *lowerName = [thisString lowercaseString];
    if ([lowerName rangeOfString:@"\n"].location == NSNotFound) {
        mutiLine = NO;
    } else {
        mutiLine = YES;
    }
    
    UIColor *color = [UIColor colorWithRed:(72.0/255.0) green:(118.0/255.0) blue:(150.0/255.0) alpha:1.0];
    UIColor *selectedColor = [UIColor colorWithRed:(145.0/255.0) green:(184.0/255.0) blue:(214.0/255.0) alpha:1.0];
    
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:selectedColor forState:UIControlStateSelected];
    [self setTitleColor:selectedColor forState:UIControlStateHighlighted];
    [self setTitleShadowColor:[UIColor colorWithRed:0.62745*0.25 green:0.6*0.25 blue:0.59375*0.25 alpha:1.0] forState:UIControlStateNormal];
    [self setTitle:thisString forState:UIControlStateNormal];
    if (mutiLine) {
        self.titleLabel.numberOfLines = 0;
        [self.titleLabel setFont:[UIFont fontWithName:@"Arial" size:64.0f]];
    } else {
        CGFloat fontSize = 128.0f;
        if (thisString.length ==2) {
            fontSize = 96.0f;
        } else if (thisString.length >=3) {
            fontSize = 64.0f;
        }
        
        [self.titleLabel setFont:[UIFont fontWithName:@"Arial" size:fontSize]];
    }
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.1;
    [self.titleLabel sizeThatFits:CGSizeMake(maxWidth, maxWidth)];
    
    frame.origin.x = pos.x - (frame.size.width/2);
    frame.origin.y = pos.y - (frame.size.height/2);
    self.frame = frame;
    self.hidden = NO;
    
    [self setAutoresizingMask:
     UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleBottomMargin |
     UIViewAutoresizingFlexibleTopMargin];
    
    [thisParentVC.view addSubview:self];
    
    if (delay) {
        [self appearAnimation:delay];
    } else {
        [self addPopAnimation];
    }
    
    self.callWhenClickedBlock = wasClickedBlock;
    
    
    return self;
}

-(KETile*)initTileWithImage:(UIImage*)thisImage
                         at:(CGPoint)pos
                      after:(float)delay
              addToParentVC:(UIViewController *)thisParentVC
                 dataObject:(id)thisDataObject
                   maxWidth:(float)maxWidth
           blockWhenClicked:(void (^)(id dataObject, KETile* tileThatWasClicked))wasClickedBlock{

    
    // init object
    UIImage *image = thisImage;
    self = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    if (self == nil) return self; // early exit on error
    
    self.parentViewController = thisParentVC;

    self.dataObject = thisDataObject;
    
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
    
    [self.parentViewController.view addSubview:self];
    
    if (delay) {
        [self appearAnimation:delay];
    } else {
        [self addPopAnimation];
    }
    
    self.callWhenClickedBlock = wasClickedBlock;
    
    
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
    if (self.callWhenClickedBlock) self.callWhenClickedBlock(self.dataObject, self);
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