//
//  AppDelegate.m
//  PolyvLiveEcommerceDemo
//
//  Created by Lincal on 2020/4/29.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "AppDelegate.h"
#import "PLVLiveSDKConfig.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 账户信息配置
    [PLVLiveSDKConfig configAccountWithUserId:@"" appId:@"" appSecret:@""];
    
    NSLog(@"SDK version: %@", PLVLiveSDKConfig.sdkVersion);
    
    return YES;
}

@end
