//
//  SFProfileHeaderView.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import "UIImage+MaskedImage.h"

#import "SFProfileHeaderView.h"

@implementation SFProfileHeaderView

- (void)awakeFromNib;
{
    [super awakeFromNib];
    
    UIImage *profileImage = [UIImage imageNamed:@"profileImage.jpg"];
    UIImage *maskImage = self.leftBoxImageView.image;
    self.leftBoxImageView.image = [profileImage maskedImageUsingMask:maskImage];
    
    UIImage *image = self.rightBoxImageView.image;
    self.rightBoxImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.rightBoxImageView.tintColor = [UIColor smokeFreeBlue];
    
    image = self.bottomBoxImageView.image;
    self.bottomBoxImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.bottomBoxImageView.tintColor = [UIColor smokeFreeGreen];
}

- (void)setBoxOffset:(CGFloat)boxOffset;
{
    _boxOffset = boxOffset;
    
    self.leftBox.transform = CGAffineTransformMakeTranslation(-boxOffset, -boxOffset);
    self.rightBox.transform = CGAffineTransformMakeTranslation(boxOffset, -boxOffset);
    self.bottomBox.transform = CGAffineTransformMakeTranslation(0, boxOffset);
}

@end
