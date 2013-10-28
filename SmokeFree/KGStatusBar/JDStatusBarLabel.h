//
//  JDStatusBarLabel.h
//
//  Based on KGStatusBar by Kevin Gibbon
//
//  Created by Markus Emrich on 10/28/13.
//  Copyright 2013 Markus Emrich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDStatusBarLabel : UIView

+ (void)showWithStatus:(NSString *)status;

+ (void)showWithStatus:(NSString *)status
          dismissAfter:(NSTimeInterval)timeInterval;

+ (void)showWithStatus:(NSString *)status
              barColor:(UIColor*)barColor;

+ (void)showWithStatus:(NSString *)status
              barColor:(UIColor*)barColor
             textColor:(UIColor*)textColor;

+ (void)showWithStatus:(NSString *)status
              barColor:(UIColor*)barColor
             textColor:(UIColor*)textColor
                  font:(UIFont*)font;

+ (void)dismiss;
+ (void)dismissAfter:(NSTimeInterval)delay;

@end
