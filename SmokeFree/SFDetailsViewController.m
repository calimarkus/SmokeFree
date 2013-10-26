//
//  SFDetailsViewController.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import "SFDetailsViewController.h"

@interface SFDetailsViewController ()

@end

@implementation SFDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:
                       [[UIImage imageNamed:@"bg_details"]
                        imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate]];
    [self.view addSubview:bg];
    
    bg.tintColor = (self.value < 0) ? [UIColor smokeFreeGreen] : [UIColor smokeFreeRed];
}

@end
