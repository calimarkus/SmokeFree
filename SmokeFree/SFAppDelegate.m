//
//  SFAppDelegate.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import <Fingertips/MBFingerTipWindow.h>

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
    
    return YES;
}

@end
