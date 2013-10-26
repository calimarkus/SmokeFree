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
    
    // seutp view
    self.view.backgroundColor = [UIColor whiteColor];
    self.bgImage.image = [[UIImage imageNamed:@"bg_details"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setDidReachTarget:(self.value < 0)];
    
    // animate in
    self.topView.frameBottom = 0;
    [UIView animateWithDuration:0.4 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.topView.frameY = 0;
    } completion:nil];
    
    // replace line chart view (so correct initalizer is used)
    [self.lineChartView removeFromSuperview];
    self.lineChartView = [[LineChartView alloc] initWithFrame:self.lineChartView.frame];
    self.lineChartView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.lineChartView belowSubview:self.topView];
    
    // update data
    [self reloadChartData];
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

- (void)reloadChartData;
{
    LineChartData *actualData = [LineChartData new];
    actualData.xMin = 1;
    actualData.xMax = 31;
    actualData.title = @"Smoke Amount";
    actualData.color = (self.value < 0) ? [UIColor smokeFreeGreen] : [UIColor smokeFreeRed];
    actualData.itemCount = 10;
    
    NSMutableArray *actualValues = [NSMutableArray new];
    for(NSUInteger i = 0; i < actualData.itemCount; ++i) {
        [actualValues addObject:@((rand() / (float)RAND_MAX) * (31 - 1) + 1)];
    }
    [actualValues sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    actualData.getData = ^(NSUInteger item) {
        float x = [actualValues[item] floatValue];
        float y = powf(2, x / 7);
        NSString *label1 = [NSString stringWithFormat:@"%d", item];
        NSString *label2 = [NSString stringWithFormat:@"%f", y];
        return [LineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
    };
    
    LineChartData *goalData = [LineChartData new];
    goalData.xMin = 1;
    goalData.xMax = 31;
    goalData.title = @"Goal";
    goalData.color = [UIColor colorWithWhite:0.66 alpha:1.0];
    goalData.itemCount = 10;
    
    NSMutableArray *goalValues = [NSMutableArray new];
    for(NSUInteger i = 0; i < goalData.itemCount; ++i) {
        [goalValues addObject:@((rand() / (float)RAND_MAX) * (31 - 1) + 1)];
    }
    [goalValues sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    goalData.getData = ^(NSUInteger item) {
        float x = [goalValues[item] floatValue];
        float y = powf(2, x / 7);
        NSString *label1 = [NSString stringWithFormat:@"%d", item];
        NSString *label2 = [NSString stringWithFormat:@"%f", y];
        return [LineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
    };
    
    self.lineChartView.yMin = 0;
    self.lineChartView.yMax = powf(2, 31 / 7) + 0.5;
    self.lineChartView.ySteps = @[@"0.0",
                         [NSString stringWithFormat:@"%.02f", self.lineChartView.yMax / 2],
                         [NSString stringWithFormat:@"%.02f", self.lineChartView.yMax]];
    self.lineChartView.data = @[actualData, goalData];
}

@end
