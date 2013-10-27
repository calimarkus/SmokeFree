//
//  SFAppDelegate.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import <Fingertips/MBFingerTipWindow.h>
#import <BoxSDK/BoxSDK.h>

#import "SFStartViewController.h"

#import "SFAppDelegate.h"

@implementation SFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // init BoxSDK
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"BoxNetCredentials" ofType:@"plist"];
    NSDictionary *credentials = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    [BoxSDK sharedSDK].OAuth2Session.clientID = credentials[@"clientID"];
    [BoxSDK sharedSDK].OAuth2Session.clientSecret = credentials[@"clientSecret"];
    NSAssert(credentials != nil, @"Please setup the BoxNetCredentials.plist first.");
    
    // setup window
    self.window = [[MBFingerTipWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.tintColor = [UIColor smokeFreeBlue];
    
    // set root controller
    UIViewController *firstController = [[SFStartViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:firstController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    [[BoxSDK sharedSDK].OAuth2Session performAuthorizationCodeGrantWithReceivedURL:url];
    return YES;
}

@end
