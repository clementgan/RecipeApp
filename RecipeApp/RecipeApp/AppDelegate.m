//
//  AppDelegate.m
//  RecipeApp
//
//  Created by clement gan on 15/02/2020.
//  Copyright © 2020 clement. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"

@interface AppDelegate ()
{
    
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    
    HomeViewController *viewController = [[HomeViewController alloc]init];
    UINavigationController *naviController = [[UINavigationController alloc]initWithRootViewController:viewController];
    self.window.rootViewController = naviController;
//    [naviController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.window makeKeyAndVisible];
    
    return YES;
}





@end
