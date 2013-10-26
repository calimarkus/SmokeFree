//
//  SFProfileCell.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import "SFProfileCell.h"

@implementation SFProfileCell

- (void)awakeFromNib;
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    self.accessoryLabel.textColor = [UIColor smokeFreeGreen];
}

+ (CGFloat)preferredHeight;
{
    return 80.0;
}

+ (NSString*)reuseIdentifier;
{
    return NSStringFromClass([self class]);
}

@end
