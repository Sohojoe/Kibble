//
//  UIAlertViewBlock.h
//  CrowdedFiction
//
//  Created by Joe on 7/18/13.
//  Copyright (c) 2013 Vidya Gamer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertViewBlock : UIAlertView <UIAlertViewDelegate>

- (id)initWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(BOOL cancelled, NSInteger buttonIndex))completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end
