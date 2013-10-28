//
//  SFStartViewController.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import <BoxSDK/BoxSDK.h>
#import "SFFileManager.h"
#import "SFProfileViewController.h"

#import "SFStartViewController.h"

@interface SFStartViewController () <BoxAuthorizationViewControllerDelegate>

@end

@implementation SFStartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Smoke Free";
        
        // add connect UI
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                               target:self action:@selector(connectWithBoxNet:)];
        
        // reuse auth token
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"BoxSDKAccessToken"];
        NSDate *tokenExpiration =  [[NSUserDefaults standardUserDefaults] objectForKey:@"BoxSDKTokenExpiration"];
        if (token && [[NSDate date] compare:tokenExpiration] == NSOrderedAscending) {
            // reuse old token
            [BoxSDK sharedSDK].OAuth2Session.accessToken = token;
            [BoxSDK sharedSDK].OAuth2Session.accessTokenExpiration = tokenExpiration;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [self didReceiveAuthToken];
        }
        
        // register for oauth completion
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oAuthComplete:)
                                                     name:BoxOAuth2OperationDidCompleteNotification object:nil];
        
        // setup status notifications style
        [JDStatusBarNotification setDefaultStyle:^JDStatusBarStyle*(JDStatusBarStyle *style) {
            style.barColor = [UIColor smokeFreeBlue];
            style.textColor = [UIColor whiteColor];
            return style;
        }];
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
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"start"]];
    [self.view addSubview:bg];
    
    UIButton *button = [[UIButton alloc] initWithFrame:self.view.bounds];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [button setTitleColor:[UIColor smokeFreeBlue] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor smokeFreeBlue] colorWithAlphaComponent:0.25] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)start:(id)sender;
{
    // copy demo data, if no access token is available
    if ([BoxSDK sharedSDK].OAuth2Session.accessToken == nil) {
        NSArray *demofiles = @[@"131027_0325", @"131027_0844", @"131027_0845", @"131027_1102", @"131027_1103"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        for (NSString *filename in demofiles) {
            NSString *sourecPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"txt"];
            NSString *targetPath = [[documentsDirectory stringByAppendingPathComponent:filename]
                                    stringByAppendingPathExtension:@"txt"];
            [[NSFileManager defaultManager] copyItemAtPath:sourecPath toPath:targetPath error:nil];
        }
    }
    
    // show profile controller
    SFProfileViewController *profileController = [[SFProfileViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:profileController animated:YES];
}

#pragma mark BOX.net

- (void)connectWithBoxNet:(id)sender;
{
    BoxAuthorizationViewController *authController = [[BoxAuthorizationViewController alloc] initWithAuthorizationURL:
                                                      [[BoxSDK sharedSDK].OAuth2Session authorizeURL] redirectURI:nil];
    authController.delegate = self;
    authController.title = @"Box.net";
    BoxFolderPickerNavigationController *navController = [[BoxFolderPickerNavigationController alloc]
                                                          initWithRootViewController:authController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)authorizationViewControllerDidStartLoading:(BoxAuthorizationViewController *)authorizationViewController; {}
- (void)authorizationViewControllerDidFinishLoading:(BoxAuthorizationViewController *)authorizationViewController; {}
- (void)authorizationViewControllerDidCancel:(BoxAuthorizationViewController *)authorizationViewController;
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
        [self didReceiveAuthToken];
    }
}

- (void)didReceiveAuthToken;
{
    [JDStatusBarNotification showWithStatus:@"Logged in into Box.net"];
    
    // start file download
    [[SFFileManager sharedInstance] loadBoxNetContentsWithProgress:^(NSString *filename) {
        [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"Received file: %@", filename]];
    } completion:^{
        [JDStatusBarNotification showWithStatus:@"Finished downloading files"];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [JDStatusBarNotification dismiss];
        });
    }];
}

@end
