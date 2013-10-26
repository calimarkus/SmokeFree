//
//  SFProfileCell.h
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import <UIKit/UIKit.h>

@interface SFProfileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *accessoryLabel;

+ (CGFloat)preferredHeight;
+ (NSString*)reuseIdentifier;

@end
