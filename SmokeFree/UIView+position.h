//
//  UIView+position.h
//
//  Created by Markus Emrich on 19.02.2013.
//  Copyleft 2010 Bynomial.
//

#import <UIKit/UIKit.h>

@interface UIView (position)

@property (nonatomic) CGPoint frameOrigin;
@property (nonatomic) CGSize  frameSize;

@property (nonatomic) CGFloat frameX;
@property (nonatomic) CGFloat frameY;

@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

@property (nonatomic) CGFloat frameWidth;
@property (nonatomic) CGFloat frameHeight;

// modifying the origin not the size.
@property (nonatomic) CGFloat frameRight;
@property (nonatomic) CGFloat frameBottom;

@end

