//
// Created by leeg on 07/05/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FZAClassParserDelegate.h"

@class FZAClassGroup;

@interface FZAModelBuildingParserDelegate : NSObject <FZAClassParserDelegate>

- (id)initWithClassGroup: (FZAClassGroup *)classGroup;

@end