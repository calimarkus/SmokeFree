//
//  SFProfileHeaderView.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import "SFProfileHeaderView.h"

@implementation SFProfileHeaderView

- (void)awakeFromNib;
{
    [super awakeFromNib];
    
    UIImage *image = self.rightBoxImageView.image;
    self.rightBoxImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.rightBoxImageView.tintColor = [UIColor smokeFreeBlue];
    
    image = self.rightBoxImageView.image;
    self.leftBoxImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.leftBoxImageView.tintColor = [UIColor smokeFreeGreen];
}

@end
