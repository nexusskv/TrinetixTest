//
//  AppDelegate.m
//  TrinetixTest
//
//  Created by rost on 12.01.15.
//  Copyright (c) 2015 Rost. All rights reserved.
//

#import "AppDelegate.h"
#import "CitiesViewController.h"
#import "DataFetcher.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    CitiesViewController *citiesVC = [[CitiesViewController alloc] init];
    self.navigContr = [[UINavigationController alloc] initWithRootViewController:citiesVC];
    self.window.rootViewController = self.navigContr;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
