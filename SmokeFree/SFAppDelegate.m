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
    self.window = [[MBFingerTipWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.tintColor = [UIColor smokeFreeBlue];
    [self.window makeKeyAndVisible];
    
    UIViewController *firstController = [[SFStartViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:firstController];
    
    [BoxSDK sharedSDK].OAuth2Session.clientID = @"6bqddxhgyukcra68wl6v3gm63t143ng6";
    [BoxSDK sharedSDK].OAuth2Session.clientSecret = @"mJ3Wh8itMMgkzkYayajqQNYfxC4kdfvO";
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    [[BoxSDK sharedSDK].OAuth2Session performAuthorizationCodeGrantWithReceivedURL:url];
    return YES;
}

@end
