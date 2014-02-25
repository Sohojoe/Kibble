//
//  KETileSystem.m
//  Kibble
//
//  Created by Joe on 2/8/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KETileSystem.h"
#import <UIKit/UIKit.h>
#import "KibbleV2.h"
#import "KibbleVM.h"

@interface KETileSystem ()
@property (nonatomic) CGPoint nextTilePosition;
@property (nonatomic) CGSize tileMargin;
@property (nonatomic) NSUInteger indent;
@property (nonatomic) NSUInteger indentSize;
@property (nonatomic,strong) KibbleV2 *kibbleBeingEdited;
@property (nonatomic, strong) KETile *tileInFocus;
@end

@implementation KETileSystem

+(KETileSystem*)defaultTileSystem{
    static KETileSystem *shared = nil;
    
    if (shared==nil) {
        // first Time Init
        shared = [[super allocWithZone:NULL] init];
    }
    return shared;
}
+(KETileSystem*)tileSystemWithSquareTileSize:(float)thisTileSize parentVC:(id)thisParentViewController{
    KETileSystem *newSystem = [[KETileSystem alloc]init];
    newSystem.tileSize = thisTileSize;
    newSystem.parentViewController = thisParentViewController;
    
    [newSystem resetNextTilePositionToTopLeft];
    return (newSystem);
}
-(void)resetNextTilePositionToTopLeft{
    self.nextTilePosition = CGPointMake(self.tileSize /2 + (self.tileMargin.width /2), self.tileSize /2 + (self.tileMargin.height /2));
}
-(void)resetNextTilePositionToMiddleLeft{
    self.nextTilePosition
    = CGPointMake(self.tileSize /2 + (self.tileMargin.width /2),
                  self.parentViewController.view.frame.size.height /2);
}


-(id)init{
    self = [super init];
    
    // defaults
    self.tileSize = 128;
    self.tileMargin = CGSizeMake(8.0, 8.0);
    self.indentSize = self.tileSize /2;
    return self;
}

-(KETile*)newTile{
    CGRect frame = CGRectMake(0, 0, self.tileSize, self.tileSize);
    KETile *ourNewTile = [[KETile alloc]initWithFrame:frame];
    
    ourNewTile.position = self.nextTilePosition;
    
    CGPoint pos =self.nextTilePosition;;
    pos.x = self.nextTilePosition.x + self.tileSize + self.tileMargin.width;
    self.nextTilePosition = pos;

    ourNewTile.parentTileSystem = self;
    
    [self.parentViewController.view addSubview:ourNewTile];
    
    [ourNewTile addPopAnimation];
 
    
    return (ourNewTile);
}
-(void)newLine{
    CGPoint pos =self.nextTilePosition;
    pos.y = self.nextTilePosition.y + self.tileSize + self.tileMargin.height;
    pos.x = self.tileSize /2 + (self.tileMargin.width /2 );
    pos.x += self.indentSize * self.indent;
    self.nextTilePosition = pos;
}
-(void)newLineAndIndent{
    self.indent++;
    [self newLine];
}
-(void)popIndent{
    self.indent--;
}
-(void)resetIndent{
    self.indent = 0;
}

-(void)editKibble:(KibbleV2 *)thisKibble{
    self.kibbleBeingEdited = thisKibble;
}

-(void)subLayerAround:(KETile*)thisTile withOptions:(NSArray*)theseOptions{
    [self newLineAndIndent];
    [theseOptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //@property (nonatomic, strong) void (^ playbackCompleteBlock)(BOOL success);
        //(void (^)(BOOL success))completeBlock;
        //BOOL (^test)(id obj, NSUInteger idx, BOOL *stop);
        //id void(^initTileBlock)(void) = obj;
        ///id void(^)(void) initTileBlock = obj;
        

        if ([obj isKindOfClass:[NSString class]]) {
            SEL option = NSSelectorFromString(obj);
            if ([self respondsToSelector:option]) {
                [self performSelector:option];
            } else {
                // oops - error
            }
        } else if ([obj isKindOfClass:[VMObject class]]){
            [self addVMObject:obj];
        } else {
            // oops - error
        }
    }];
}
-(KETile*)addVMObject:(VMObject*)thisVMObject{
    KETile *newTile = [self newTile];
    newTile.display = thisVMObject.name;//.description;
    [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
        self.tileInFocus.display = newTile.display;
//        [newTile remove];
    }];
    return newTile;
}


-(KETile*)addWhatNextTile{
    [self resetIndent];
    [self newLine];
    KETile *newTile = [self newTile];
    newTile.display = @"...?";
    self.tileInFocus = newTile;
    [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
        // options: newKibble, myKibbles, friends
        [self subLayerAround:newTile withOptions:@[@"newKibbleTile",
                                                   @"listMyKibbleTile",
                                                   @"listMyFriendsTile",
                                                   ]];
    }];
    return (newTile);
}

-(KETile*)newKibbleTile{
    KETile *newTile = [self newTile];
    newTile.display = @"New Kibble";
    [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
        // create new kibble
        
        // options: equals, functions
    }];
    return (newTile);
}
-(KETile*)listMyKibbleTile{
    KETile *newTile = [self newTile];
    newTile.display = @"My Kibbles";
    // notes grey out if we have no kibbles
    [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
        // display my Kibbles
        [self subLayerAround:newTile withOptions:self.kibbleBeingEdited.myKibbles];
    }];
    return (newTile);
}
-(KETile*)listMyFriendsTile{
    KETile *newTile = [self newTile];
    newTile.display = @"My Friends";
    // notes grey out if we have no options
    [newTile blockWhenClicked:^(id dataObject, KETile *tileThatWasClicked) {
        // display friends
        [self subLayerAround:newTile withOptions:self.kibbleBeingEdited.myKibbles];
    }];
    return (newTile);
}


@end
