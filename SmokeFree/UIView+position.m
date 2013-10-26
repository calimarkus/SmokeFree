//
//  UIView+position.m
//
//  Created by Markus Emrich on 19.02.2013.
//  Copyleft 2010 Bynomial.
//

#import "UIView+position.h"


@implementation UIView (position)

- (CGPoint)frameOrigin {
  return self.frame.origin;
}

- (void)setFrameOrigin:(CGPoint)frameOrigin {
  self.frame = CGRectMake(frameOrigin.x, frameOrigin.y, self.frame.size.width, self.frame.size.height);
}

- (CGSize)frameSize {
  return self.frame.size;
}

- (void)setFrameSize:(CGSize)frameSize {
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                          frameSize.width, frameSize.height);
}

- (CGFloat)frameX {
	return self.frame.origin.x;
}

- (void)setFrameX:(CGFloat)frameX {
	self.frame = CGRectMake(frameX, self.frame.origin.y,
							self.frame.size.width, self.frame.size.height);
}

- (CGFloat)frameY {
	return self.frame.origin.y;
}

- (void)setFrameY:(CGFloat)frameY {
	self.frame = CGRectMake(self.frame.origin.x, frameY,
							self.frame.size.width, self.frame.size.height);
}

- (CGFloat)centerX {
	return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
	self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
	return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
	self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)frameWidth {
  return self.frame.size.width;
}

- (void)setFrameWidth:(CGFloat)frameWidth {
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                          frameWidth, self.frame.size.height);
}

- (CGFloat)frameHeight {
  return self.frame.size.height;
}

- (void)setFrameHeight:(CGFloat)frameHeight {
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                          self.frame.size.width, frameHeight);
}

- (CGFloat)frameRight {
	return self.frame.origin.x + self.frame.size.width;
}

- (void)setFrameRight:(CGFloat)frameRight {
	self.frame = CGRectMake(frameRight - self.frame.size.width, self.frame.origin.y,
							self.frame.size.width, self.frame.size.height);
}

- (CGFloat)frameBottom {
	return self.frame.origin.y + self.frame.size.height;
}

- (void)setFrameBottom:(CGFloat)frameBottom {
	self.frame = CGRectMake(self.frame.origin.x, frameBottom - self.frame.size.height,
							self.frame.size.width, self.frame.size.height);
}

@end




