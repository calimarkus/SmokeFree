//
//  UIImage+MaskedImage.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import "UIImage+MaskedImage.h"

@implementation UIImage (MaskedImage)

- (UIImage*)maskedImageUsingMask:(UIImage *)maskImage;
{
	CGImageRef maskRef = maskImage.CGImage;
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask(self.CGImage, mask);
    
	return [UIImage imageWithCGImage:masked];
}

@end
