//
//  SFStartViewController.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import "SFProfileViewController.h"

#import "SFStartViewController.h"

@interface SFStartViewController ()

@end

@implementation SFStartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Smoke Free";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:self.view.bounds];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [button setTitle:@"Start" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor smokeFreeBlue] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor smokeFreeBlue] colorWithAlphaComponent:0.25] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)start:(id)sender;
{
    SFProfileViewController *profileController = [[SFProfileViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:profileController animated:YES];
}

@end
