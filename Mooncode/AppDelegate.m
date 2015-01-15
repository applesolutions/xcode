//
//  AppDelegate.m
//  208
//
//  Created by amaury soviche on 11/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "AppDelegate.h"
#import "ScrollViewController.h"
#import <Parse/Parse.h>



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //DELETE EVERYTHING *******
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    //*************************
    
//    [[NSUserDefaults standardUserDefaults] setObject:@"https://fedbythreads.myshopify.com" forKey:@"website_url"];//FEDBYTHREADS
//    [[NSUserDefaults standardUserDefaults] setObject:@"73aeb1d0858d068d68dddc7a805e68b7" forKey:@"shopify_token"];
    
//    [[NSUserDefaults standardUserDefaults] setObject:@"https://angeloqtr.myshopify.com" forKey:@"website_url"];//angelo
//    [[NSUserDefaults standardUserDefaults] setObject:@"baca8e6e8552aa16eb3a7f5457b8d22c" forKey:@"shopify_token"];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"https://buyonesnap.myshopify.com" forKey:@"website_url"];
    [[NSUserDefaults standardUserDefaults] setObject:@"14f27c433cf58b1cf66da2d39228ce32" forKey:@"shopify_token"];
    [[NSUserDefaults standardUserDefaults] setObject:@"http://fedbythreads.com" forKey:@"website_cart_url"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"urlForTerms"];
    [[NSUserDefaults standardUserDefaults] setObject:@"FedByThreads" forKey:@"twitterName"];
    [[NSUserDefaults standardUserDefaults] setObject:@"info@fedbythreads.com" forKey:@"supportUrl"];
    [[NSUserDefaults standardUserDefaults] setObject:@"smart_collections" forKey:@"collectionType"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"areCollectionsDisplayed"];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"$" forKey:@"currency"];
    
    //colorNavBar
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @172 ,  @"red"   ,
                                                                                                    @34 ,  @"green" ,
                                                                                                    @52 ,  @"blue"  ,  nil]
                                              forKey:@"colorNavBar"];

    //colorSettingsView
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @48 ,  @"red"   ,
                                                                                                    @48 ,  @"green" ,
                                                                                                    @48 ,  @"blue"  ,  nil]
                                              forKey:@"colorSettingsView"];
    
    //colorButtons
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @156 ,  @"red"   ,
                                                                                                    @31 ,  @"green" ,
                                                                                                    @57 ,  @"blue"  ,  nil]
                                              forKey:@"colorButtons"];
    
    //colorViewTitleCollection
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @172 ,  @"red"   ,
                                                                                                    @34 ,  @"green" ,
                                                                                                    @52 ,  @"blue"  ,  nil]
                                              forKey:@"colorViewTitleCollection"];
    //ColorLabelCollections
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @255 ,  @"red"   ,
                                                                                                    @255 ,  @"green" ,
                                                                                                    @255 ,  @"blue"  ,  nil]
                                              forKey:@"colorLabelCollections"];
    //backgroundColor
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @235 ,  @"red"   ,
                                                                                                    @235 ,  @"green" ,
                                                                                                    @235 ,  @"blue"  ,
                                                                                                    @1 ,  @"alpha", nil]
                                              forKey:@"backgroundColor"];
    
    //CUSTOM collections ******************************************************************************************
    //**************************************************************************************************************
    
    NSArray *arrayCustomCollectionsIds = [NSArray arrayWithObjects:
//                                          @"5714232",
//                                          @"9202724",
//                                          @"7935780",
//                                          @"26412852",
//                                          @"26297760",
//                                          @"8192184",
//                                          @"26179840",
//                                          @"26909296",
//                                          @"12889797",
//                                          @"23039669",
//                                          @"14395853",
//                                          @"23181225",
                                          nil];
    
    // NEVER REMOVE THIS LINE !!!! ********
    [[NSUserDefaults standardUserDefaults] setObject:arrayCustomCollectionsIds forKey:@"arrayCustomCollectionsIds"]; // NEVER REMOVE THIS LINE !!!! ********
    // NEVER REMOVE THIS LINE !!!! ********
    
    //**************************************************************************************************************
    //**************************************************************************************************************
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setAppearance];
    [self setParse];
    [self setNotificationsWithApplication:application];

    return YES;
}

-(void) setParse{
    [Parse setApplicationId:@"otmiHCRLKGwtFbUowQCUAZAslE17xkOii8yicVrK"
                  clientKey:@"eTm6zxTQeaV33ZSoSYguQ6YUlZ4nIjMyr197cPgd"];
}

-(void) setNotificationsWithApplication: (UIApplication *)application{
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
}

-(void) setAppearance{
    [[UINavigationBar appearance] setBarTintColor:
     [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"red"] floatValue] / 255
                     green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"green"] floatValue] / 255
                      blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"blue"] floatValue] / 255
                     alpha:1]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                                            NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Regular" size:19.0f],
                                                            }];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //     Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:@"Global" forKey:@"channels"];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"enter background");
    
    if ([[NSUserDefaults standardUserDefaults] synchronize]) {
        NSLog(@"back saved ");
    }else{
        NSLog(@"not back saved ");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
