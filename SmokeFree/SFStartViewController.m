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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oAuthComplete:)
                                                     name:BoxOAuth2OperationDidCompleteNotification object:nil];
        
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"BoxSDKAccessToken"];
        NSDate *tokenExpiration =  [[NSUserDefaults standardUserDefaults] objectForKey:@"BoxSDKTokenExpiration"];
        if (token || [[NSDate date] compare:tokenExpiration] == NSOrderedAscending) {
            // reuse old token
            [BoxSDK sharedSDK].OAuth2Session.accessToken = token;
            [BoxSDK sharedSDK].OAuth2Session.accessTokenExpiration = tokenExpiration;
        } else {
            // show auth UI
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                                   target:self action:@selector(connectWithBoxNet:)];
        }
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
    
    NSString *token = [BoxSDK sharedSDK].OAuth2Session.accessToken;
    NSDate *tokenExpiration = [BoxSDK sharedSDK].OAuth2Session.accessTokenExpiration;
    if (token) {
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"BoxSDKAccessToken"];
        [[NSUserDefaults standardUserDefaults] setObject:tokenExpiration forKey:@"BoxSDKTokenExpiration"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.navigationItem.rightBarButtonItem = nil;
    }
}

@end
