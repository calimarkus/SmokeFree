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
    self.rightBoxImageView.tintColor = [UIColor colorWithRed:0.00f green:0.68f blue:0.94f alpha:1.00f];
    
    image = self.rightBoxImageView.image;
    self.leftBoxImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.leftBoxImageView.tintColor = [UIColor colorWithRed:0.55f green:0.78f blue:0.25f alpha:1.00f];
}

@end
