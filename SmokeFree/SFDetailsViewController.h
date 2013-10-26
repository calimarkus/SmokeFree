//
//  SFDetailsViewController.h
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import <UIKit/UIKit.h>

@class LineChartView;

@interface SFDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *positiveImage;
@property (weak, nonatomic) IBOutlet UIImageView *negativeImage;

@property (strong, nonatomic) IBOutlet LineChartView *lineChartView;

@property (nonatomic, assign) CGFloat value;

@end
