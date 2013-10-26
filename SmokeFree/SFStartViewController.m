//
//  SFStartViewController.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import <BoxSDK/BoxSDK.h>
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
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                               target:self action:@selector(connectWithBoxNet:)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oAuthComplete:)
                                                     name:BoxOAuth2OperationDidCompleteNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark BOX.net

- (void)connectWithBoxNet:(id)sender;
{
    UIViewController *authorizationController = [[BoxAuthorizationViewController alloc] initWithAuthorizationURL:
                                                 [[BoxSDK sharedSDK].OAuth2Session authorizeURL] redirectURI:nil];
    [self presentViewController:authorizationController animated:YES completion:nil];
}

- (void)oAuthComplete:(NSNotification*)notification;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
