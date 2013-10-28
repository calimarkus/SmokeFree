//
//  JDStatusBarLabel.m
//
//  Based on KGStatusBar by Kevin Gibbon
//
//  Created by Markus Emrich on 10/28/13.
//  Copyright 2013 Markus Emrich. All rights reserved.
//

#import "KGStatusBar.h"

@interface KGStatusBar ()
@property (nonatomic, strong, readonly) UIWindow *overlayWindow;
@property (nonatomic, strong, readonly) UIView *topBar;
@property (nonatomic, strong, readonly) UILabel *stringLabel;

@property (nonatomic, strong) UIColor *defaultBarColor;
@property (nonatomic, strong) UIColor *defaultTextColor;
@property (nonatomic, strong) UIFont *defaultFont;
@end

@implementation KGStatusBar

@synthesize overlayWindow = _overlayWindow;
@synthesize stringLabel = _stringLabel;
@synthesize topBar = _topBar;

#pragma mark class methods

+ (KGStatusBar*)sharedView {
    static dispatch_once_t once;
    static KGStatusBar *sharedView;
    dispatch_once(&once, ^ {
        sharedView = [[KGStatusBar alloc] initWithFrame:
                      [[UIScreen mainScreen] bounds]];
        
        // set defaults
        sharedView.defaultBarColor = [UIColor whiteColor];
        sharedView.defaultTextColor = [UIColor grayColor];
        sharedView.defaultFont = [UIFont systemFontOfSize:12.0];
    });
    return sharedView;
}

+ (void)showWithStatus:(NSString *)status
          dismissAfter:(NSTimeInterval)timeInterval;
{
    [self showWithStatus:status];
    [self dismissAfter:timeInterval];
}

+ (void)showWithStatus:(NSString *)status;
{
    [self showWithStatus:status
                barColor:[[self sharedView] defaultBarColor]
               textColor:[[self sharedView] defaultTextColor]
                    font:[[self sharedView] defaultFont]];
}

+ (void)showWithStatus:(NSString *)status
              barColor:(UIColor*)barColor;
{
    [self showWithStatus:status
                barColor:barColor
               textColor:[[self sharedView] defaultTextColor]
                    font:[[self sharedView] defaultFont]];
}

+ (void)showWithStatus:(NSString *)status
              barColor:(UIColor*)barColor
             textColor:(UIColor*)textColor;
{
    [self showWithStatus:status
                barColor:barColor
               textColor:textColor
                    font:[[self sharedView] defaultFont]];
}

+ (void)showWithStatus:(NSString *)status
              barColor:(UIColor*)barColor
             textColor:(UIColor*)textColor
                  font:(UIFont*)font;
{
    [[KGStatusBar sharedView] showWithStatus:status
                                    barColor:barColor
                                   textColor:textColor
                                        font:font];
}

+ (void)dismiss;
{
    [[KGStatusBar sharedView] dismiss];
}

+ (void)dismissAfter:(NSTimeInterval)delay;
{
    [[KGStatusBar sharedView] dismiss];
    [KGStatusBar performSelector:@selector(dismiss) withObject:self afterDelay:delay];
}

#pragma mark implementation

- (id)initWithFrame:(CGRect)frame;
{
	
    if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)showWithStatus:(NSString *)status
              barColor:(UIColor*)barColor
             textColor:(UIColor*)textColor
                  font:(UIFont*)font;
{
    [self.overlayWindow addSubview:self];
    [self.overlayWindow setHidden:NO];
    [self.topBar setHidden:NO];
    self.topBar.backgroundColor = barColor;
    self.stringLabel.frame = CGRectMake(0, 2, self.topBar.bounds.size.width, self.topBar.bounds.size.height-2);
    self.stringLabel.alpha = 0.0;
    self.stringLabel.hidden = NO;
    self.stringLabel.text = status;
    self.stringLabel.textColor = textColor;
    self.stringLabel.font = font;
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
        [self.topBar removeFromSuperview];
        _topBar = nil;
        
        [self.overlayWindow removeFromSuperview];
        _overlayWindow = nil;
    }];
}

#pragma mark lazy views

- (UIWindow *)overlayWindow;
{
    if(!_overlayWindow) {
        _overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayWindow.backgroundColor = [UIColor clearColor];
        _overlayWindow.userInteractionEnabled = NO;
        _overlayWindow.windowLevel = UIWindowLevelStatusBar;
    }
    return _overlayWindow;
}

- (UIView *)topBar;
{
    if(!_topBar) {
        _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.overlayWindow.frame.size.width, 20.0)];
        _topBar.alpha = 0.0;
        [self.overlayWindow addSubview:_topBar];
    }
    return _topBar;
}

- (UILabel *)stringLabel;
{
    if (_stringLabel == nil) {
        _stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_stringLabel.backgroundColor = [UIColor clearColor];
		_stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _stringLabel.textAlignment = NSTextAlignmentCenter;
		_stringLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    if(!_stringLabel.superview)
        [self.topBar addSubview:_stringLabel];
    
    return _stringLabel;
}

@end
