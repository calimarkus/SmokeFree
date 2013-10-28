//
//  KGStatusBar.m
//
//  Created by Kevin Gibbon on 2/27/13.
//  Copyright 2013 Kevin Gibbon. All rights reserved.
//  @kevingibbon
//

#import "KGStatusBar.h"

@interface KGStatusBar ()
    @property (nonatomic, strong, readonly) UIWindow *overlayWindow;
    @property (nonatomic, strong, readonly) UIView *topBar;
    @property (nonatomic, strong) UILabel *stringLabel;
@end

@implementation KGStatusBar

@synthesize topBar, overlayWindow, stringLabel;

+ (KGStatusBar*)sharedView {
    static dispatch_once_t once;
    static KGStatusBar *sharedView;
    dispatch_once(&once, ^ { sharedView = [[KGStatusBar alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}

+ (void)showSuccessWithStatus:(NSString*)status
{
    [KGStatusBar showWithStatus:status];
    [KGStatusBar performSelector:@selector(dismiss) withObject:self afterDelay:2.0 ];
}

+ (void)showWithStatus:(NSString*)status {
    [[KGStatusBar sharedView] showWithStatus:status
                                    barColor:[UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f]
                                   textColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
}

+ (void)showErrorWithStatus:(NSString*)status {
    [[KGStatusBar sharedView] showWithStatus:status
                                    barColor:[UIColor colorWithRed:97.0/255.0 green:4.0/255.0 blue:4.0/255.0 alpha:1.0]
                                   textColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [KGStatusBar performSelector:@selector(dismiss) withObject:self afterDelay:2.0 ];
}

+ (void)dismiss {
    [[KGStatusBar sharedView] dismiss];
}

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)showWithStatus:(NSString *)status barColor:(UIColor*)barColor textColor:(UIColor*)textColor{
    if(!self.superview)
        [self.overlayWindow addSubview:self];
    [self.overlayWindow setHidden:NO];
    [self.topBar setHidden:NO];
    self.topBar.backgroundColor = barColor;
    NSString *labelText = status;
    CGRect labelRect = CGRectInset(CGRectOffset(self.topBar.bounds, 0, 3.0), 0, 3.0);
    self.stringLabel.frame = labelRect;
    self.stringLabel.alpha = 0.0;
    self.stringLabel.hidden = NO;
    self.stringLabel.text = labelText;
    self.stringLabel.textColor = textColor;
    [UIView animateWithDuration:0.4 animations:^{
        self.topBar.alpha = 1.0;
        self.stringLabel.alpha = 1.0;
    }];
    [self setNeedsDisplay];
}

- (void)dismiss;
{
    [UIView animateWithDuration:0.4 animations:^{
        self.stringLabel.alpha = 0.0;
        self.topBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        [topBar removeFromSuperview];
        topBar = nil;
        
        [overlayWindow removeFromSuperview];
        overlayWindow = nil;
    }];
}

- (UIWindow *)overlayWindow {
    if(!overlayWindow) {
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.userInteractionEnabled = NO;
        overlayWindow.windowLevel = UIWindowLevelStatusBar;
    }
    return overlayWindow;
}

- (UIView *)topBar {
    if(!topBar) {
        topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, overlayWindow.frame.size.width, 20.0)];
        topBar.alpha = 0.0;
        [overlayWindow addSubview:topBar];
    }
    return topBar;
}

- (UILabel *)stringLabel {
    if (stringLabel == nil) {
        stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		stringLabel.textColor = [UIColor whiteColor];
		stringLabel.backgroundColor = [UIColor clearColor];
		stringLabel.adjustsFontSizeToFitWidth = YES;
        stringLabel.textAlignment = NSTextAlignmentCenter;
		stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		stringLabel.font = [UIFont systemFontOfSize:12.0];
    }
    
    if(!stringLabel.superview)
        [self.topBar addSubview:stringLabel];
    
    return stringLabel;
}

@end
