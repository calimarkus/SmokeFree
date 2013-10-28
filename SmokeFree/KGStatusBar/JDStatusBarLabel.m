//
//  JDStatusBarLabel.m
//
//  Based on KGStatusBar by Kevin Gibbon
//
//  Created by Markus Emrich on 10/28/13.
//  Copyright 2013 Markus Emrich. All rights reserved.
//

#import "JDStatusBarLabel.h"

@interface JDStatusBarLabel ()
@property (nonatomic, strong, readonly) UIWindow *overlayWindow;
@property (nonatomic, strong, readonly) UIView *topBar;
@property (nonatomic, strong, readonly) UILabel *textLabel;

@property (nonatomic, strong) JDStatusBarStyle *defaultStyle;
@property (nonatomic, strong) NSMutableDictionary *userStyles;
@end

@implementation JDStatusBarLabel

@synthesize overlayWindow = _overlayWindow;
@synthesize textLabel = _textLabel;
@synthesize topBar = _topBar;

#pragma mark class methods

+ (JDStatusBarLabel*)sharedInstance {
    static dispatch_once_t once;
    static JDStatusBarLabel *sharedInstance;
    dispatch_once(&once, ^ {
        sharedInstance = [[JDStatusBarLabel alloc] initWithFrame:
                          [[UIScreen mainScreen] bounds]];
        
        // set defaults
        JDStatusBarStyle *defaultStyle = [[JDStatusBarStyle alloc] init];
        defaultStyle.barColor = [UIColor whiteColor];
        defaultStyle.textColor = [UIColor grayColor];
        defaultStyle.font = [UIFont systemFontOfSize:12.0];
        sharedInstance.defaultStyle = defaultStyle;
        
        // prepare userStyles
        sharedInstance.userStyles = [NSMutableDictionary dictionary];
    });
    return sharedInstance;
}

+ (void)showWithStatus:(NSString *)status;
{
    [[self sharedInstance] showWithStatus:status
                                styleName:nil];
}

+ (void)showWithStatus:(NSString *)status
             styleName:(NSString*)styleName;
{
    [[self sharedInstance] showWithStatus:status
                                styleName:styleName];
}

+ (void)showWithStatus:(NSString *)status
          dismissAfter:(NSTimeInterval)timeInterval;
{
    [self showWithStatus:status
            dismissAfter:timeInterval
               styleName:nil];
}

+ (void)showWithStatus:(NSString *)status
          dismissAfter:(NSTimeInterval)timeInterval
             styleName:(NSString*)styleName;
{
    [self showWithStatus:status
               styleName:styleName];
    [self dismissAfter:timeInterval];
}

+ (void)dismiss;
{
    [[JDStatusBarLabel sharedInstance] dismiss];
}

+ (void)dismissAfter:(NSTimeInterval)delay;
{
    [[JDStatusBarLabel sharedInstance] dismiss];
    [JDStatusBarLabel performSelector:@selector(dismiss) withObject:self afterDelay:delay];
}

+ (void)setDefaultStyle:(JDPrepareStyleBlock)prepareBlock;
{
    NSAssert(prepareBlock != nil, @"No prepareBlock provided");
    
    JDStatusBarStyle *style = [[self sharedInstance].defaultStyle copy];
    [JDStatusBarLabel sharedInstance].defaultStyle = prepareBlock(style);
}

+ (NSString*)addStyleNamed:(NSString*)identifier
                   prepare:(JDPrepareStyleBlock)prepareBlock;
{
    NSAssert(identifier != nil, @"No identifier provided");
    NSAssert(prepareBlock != nil, @"No prepareBlock provided");
    
    JDStatusBarStyle *style = [[self sharedInstance].defaultStyle copy];
    [[self sharedInstance].userStyles setObject:prepareBlock(style) forKey:identifier];
    return identifier;
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
             styleName:(NSString*)styleName;
{
    JDStatusBarStyle *style = nil;
    if (styleName != nil) {
        style = self.userStyles[styleName];
    }
    
    if (style != nil) {
        [self showWithStatus:status style:style];
    } else {
        [self showWithStatus:status style:self.defaultStyle];
    }
}

- (void)showWithStatus:(NSString *)status
                 style:(JDStatusBarStyle*)style;
{
    [self.overlayWindow addSubview:self];
    [self.overlayWindow setHidden:NO];
    
    self.textLabel.textColor = style.textColor;
    self.textLabel.font = style.font;
    self.textLabel.frame = CGRectMake(0, 2, self.topBar.bounds.size.width, self.topBar.bounds.size.height-2);
    self.textLabel.text = status;
    
    self.topBar.hidden = NO;
    self.topBar.backgroundColor = style.barColor;
    [UIView animateWithDuration:0.4 animations:^{
        self.topBar.alpha = 1.0;
    }];
    [self setNeedsDisplay];
}

- (void)dismiss;
{
    [UIView animateWithDuration:0.4 animations:^{
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
    if(_overlayWindow == nil) {
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
    if(_topBar == nil) {
        _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.overlayWindow.frame.size.width, 20.0)];
        _topBar.alpha = 0.0;
        [self.topBar addSubview:self.textLabel];
        [self.overlayWindow addSubview:_topBar];
    }
    return _topBar;
}

- (UILabel *)textLabel;
{
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_textLabel.backgroundColor = [UIColor clearColor];
		_textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _textLabel.textAlignment = NSTextAlignmentCenter;
		_textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    return _textLabel;
}

@end

@implementation JDStatusBarStyle

- (instancetype)copyWithZone:(NSZone *)zone;
{
    JDStatusBarStyle *style = [[[self class] allocWithZone:zone] init];
    style.barColor = self.barColor;
    style.textColor = self.textColor;
    style.font = self.font;
    return style;
}

@end

