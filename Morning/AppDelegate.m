//
//  AppDelegate.m
//  Morning
//
//  Created by Mike Choi on 1/5/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "AppDelegate.h"
#import "ACPReminder.h"
#import "MainViewController.h"
#import "CZMainViewController.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>


@interface AppDelegate ()
@property (strong, nonatomic) MainViewController *mainVC;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    //twitter setup with fabric
    
    [[Twitter sharedInstance] startWithConsumerKey:@"rlxIipMxLCbt099015yNjyQn2" consumerSecret:@"HZO60ey6uoSM9sFJjYpozdy4EQRd7ullPnlQHi7OhqGVOjn6TJ"];

    [Fabric with:@[[Twitter sharedInstance]]];
    
  if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showTutorial"])
    {
       self.mainVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"sickaf"];
        self.window.rootViewController = self.mainVC;
    }
    else if(![[NSUserDefaults standardUserDefaults] boolForKey:@"showTutorial"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showTutorial"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"temp"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"1"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"twitter"];
        [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:@"slidesReadDay"];
         //news
        NSMutableArray *newsSettings = [[NSMutableArray alloc]init];
        NSMutableArray *searchSettings = [[NSMutableArray alloc]init];
        NSMutableArray *stockList = [[NSMutableArray alloc]initWithObjects:@"T", @"YHOO", @"GOOG", nil];
        
        for (int i = 0;  i<=9; i++){
            [newsSettings insertObject:[NSNumber numberWithBool:NO] atIndex:i];
            [searchSettings insertObject:[NSNumber numberWithBool:NO] atIndex:i];
        }
        
        [newsSettings replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:YES]];
        [searchSettings replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:YES]];
        [[NSUserDefaults standardUserDefaults] setObject:newsSettings forKey:@"news"];
        [[NSUserDefaults standardUserDefaults] setObject:searchSettings forKey:@"search"];
        [[NSUserDefaults standardUserDefaults] setObject:stockList forKey:@"stocks"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:@"test"] forKey:@"read"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSDate *lastOpened = [[NSUserDefaults standardUserDefaults]objectForKey:@"lastopened"];
    if (lastOpened != nil){
        NSTimeInterval diff = [lastOpened timeIntervalSinceNow];
        if (diff > 60 * 60 * 24 * 1){
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"lastopened"];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"read"];
        }
    }
    else{
        [[NSUserDefaults standardUserDefaults]setObject:[NSDate date] forKey:@"lastopened"];
    }
    
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    ACPReminder * localNotifications = [ACPReminder sharedManager];
    //Settings
    localNotifications.messages = @[@"Good morning. Check what's going on rn", @"Get your morning feed with your breakfast!", @"Morning!", @"Come and I shall enlighten you", @"What's good? See what's going on right now!"];
    localNotifications.timePeriods = @[@(2)]; //days
    localNotifications.appDomain = @"MJC.Morning";
    localNotifications.randomMessage = YES; //By default is NO (optional)
    localNotifications.circularTimePeriod = YES; // By default is NO (optional)
    
    [localNotifications createLocalNotification];
    
    [self.mainVC.weatherVC.locationManager stopUpdatingLocation];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"slidesReadDay"];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[ACPReminder sharedManager] checkIfLocalNotificationHasBeenTriggered];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    
     [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
