//
//  SFDetailsViewController.h
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import <UIKit/UIKit.h>

@class SFFile;
@class LCLineChartView;

@interface SFDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet LCLineChartView *lineChartView;

@property (nonatomic, strong) SFFile *file;

@end
