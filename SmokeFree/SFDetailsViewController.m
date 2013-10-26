//
//  SFDetailsViewController.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import <ios-linechart/LineChartView.h>

#import "SFDetailsViewController.h"

@interface SFDetailsViewController ()

@end

@implementation SFDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.bgImage.image = [[UIImage imageNamed:@"bg_details"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setDidReachTarget:(self.value < 0)];
    
    // animate in
    self.topView.frameBottom = 0;
    [UIView animateWithDuration:0.4 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.topView.frameY = 0;
    } completion:nil];
    
    [self addChart];
}

- (void)setDidReachTarget:(BOOL)didReachTarget;
{
    if (didReachTarget) {
        self.bgImage.tintColor = [UIColor smokeFreeGreen];
        self.titleLabel.text = @"That's how we roll!";
        self.subTitleLabel.text = @"You reached your goal today!";
        self.positiveImage.hidden = NO;
        self.negativeImage.hidden = YES;
    } else {
        self.bgImage.tintColor = [UIColor smokeFreeRed];
        self.titleLabel.text = @"Come on!";
        if (self.value < 1.0) {
            self.subTitleLabel.text = @"So close… tomorrow you can do it!";
        } else {
            self.subTitleLabel.text = @"You can do better! You wanted this, no?";
        }
        self.positiveImage.hidden = YES;
        self.negativeImage.hidden = NO;
    }
}

- (void)addChart;
{
    LineChartData *d = [LineChartData new];
    d.xMin = 1;
    d.xMax = 31;
    d.title = @"The title for the legend";
    d.color = [UIColor redColor];
    d.itemCount = 10;
    
    NSMutableArray *vals = [NSMutableArray new];
    for(NSUInteger i = 0; i < d.itemCount; ++i) {
        [vals addObject:@((rand() / (float)RAND_MAX) * (31 - 1) + 1)];
    }
    [vals sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    d.getData = ^(NSUInteger item) {
        float x = [vals[item] floatValue];
        float y = powf(2, x / 7);
        NSString *label1 = [NSString stringWithFormat:@"%d", item];
        NSString *label2 = [NSString stringWithFormat:@"%f", y];
        return [LineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
    };
    
    LineChartView *chartView = [[LineChartView alloc] initWithFrame:CGRectMake(20, 350, 300, 300)];
    chartView.yMin = 0;
    chartView.yMax = powf(2, 31 / 7) + 0.5;
    chartView.ySteps = @[@"0.0",
                         [NSString stringWithFormat:@"%.02f", chartView.yMax / 2],
                         [NSString stringWithFormat:@"%.02f", chartView.yMax]];
    chartView.data = @[d];
    
    [self.view addSubview:chartView];
}

@end
