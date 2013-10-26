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
    UIImage *maskImage = self.profileImageView.image;
    self.profileImageView.image = [profileImage maskedImageUsingMask:maskImage];
    
    UIImage *image = self.rightBoxImageView.image;
    self.rightBoxImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.rightBoxImageView.tintColor = [UIColor smokeFreeBlue];
    
    image = self.rightBoxImageView.image;
    self.leftBoxImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.leftBoxImageView.tintColor = [UIColor smokeFreeGreen];
}

@end
