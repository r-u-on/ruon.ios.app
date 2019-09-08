//
//  AppDelegate.m
//  R-U-ON
//
//  Created by YUVAL PERLOV on 1/1/14.
//  Copyright (c) 2014 ruon. All rights reserved.
//

#import "AppDelegate.h"
#import "Settings.h"
#import "NotificationsRegister.h"
#import "Table.h"
#import "Tabs.h"

@implementation AppDelegate


-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Settings defaults];
    return YES;
}


- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
	[NotificationsRegister registerNotifications:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"Error registering for notifications");
	NSLog(@"%@", [error localizedDescription]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSString *badgeString =  [[userInfo objectForKey:@"aps"] objectForKey:@"badge"];
    if (badgeString!=nil) {
        application.applicationIconBadgeNumber = [badgeString intValue];
        [AlarmsTable startRefresh];
        [Tabs badgeUpdate];
	}
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
