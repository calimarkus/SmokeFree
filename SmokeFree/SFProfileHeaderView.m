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
    
    image = self.bottomBoxImageView.image;
    self.bottomBoxImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.bottomBoxImageView.tintColor = [UIColor smokeFreeGreen];
}

@end
