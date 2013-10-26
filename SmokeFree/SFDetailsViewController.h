//
//  SFDetailsViewController.h
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import <UIKit/UIKit.h>

@interface SFDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (nonatomic, assign) CGFloat value;

@end
