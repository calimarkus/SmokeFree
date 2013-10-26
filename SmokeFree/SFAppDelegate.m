//
//  SFAppDelegate.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import "SFProfileViewController.h"

#import "SFAppDelegate.h"

@implementation SFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController: [[SFProfileViewController alloc] init]];
    
    return YES;
}

@end
