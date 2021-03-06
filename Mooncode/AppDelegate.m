//
//  AppDelegate.m
//  208
//
//  Created by amaury soviche on 11/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "FCFileManager.h"
#import "Store.h"
#import <BuddyBuildSDK/BuddyBuildSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [BuddyBuildSDK setup];
    
    // Override point for customization after application launch.
    
    //DELETE EVERYTHING *******
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    //*************************
    //

//        [[NSUserDefaults standardUserDefaults] setObject:@"https://dprisa-mexico.myshopify.com" forKey:@"website_url"];
//        [[NSUserDefaults standardUserDefaults] setObject:@"https://pet-shop-buoy.myshopify.com" forKey:@"website_url"];
//        [[NSUserDefaults standardUserDefaults] setObject:@"https://shuzia.myshopify.com" forKey:@"website_url"];
//        [[NSUserDefaults standardUserDefaults] setObject:@"https://piecebypiece.myshopify.com" forKey:@"website_url"];
    
    
//    [[NSUserDefaults standardUserDefaults] setObject:@"https://wall-society.myshopify.com" forKey:@"website_url"];
    [[NSUserDefaults standardUserDefaults] setObject:@"https://applesolutions.myshopify.com" forKey:@"website_url"];
    [[NSUserDefaults standardUserDefaults] setObject:@"http://applesolutions.dk" forKey:@"website_cart_url"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isInstagramIntegrated"];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"shopify" forKey:@"shopType"];
    [[NSUserDefaults standardUserDefaults] setObject:@"https://checkout.shopify.com" forKey:@"checkoutUrl"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"areCollectionsDisplayed"];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"instagramId"] == nil) { //298508107
        [[NSUserDefaults standardUserDefaults] setObject:@[@""] forKey:@"instagramId"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"twitterName"] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"twitterName"];
    }
    
    
//    [Flurry startSession:@""];
    
    
    //colorNavBar
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] == nil) //secondary
        [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @44 ,  @"red"   ,
                                                                                                    @44 ,  @"green" ,
                                                                                                    @44 ,  @"blue"  ,
                                                                                                    @1.0, @"alpha", nil]
                                              forKey:@"colorNavBar"];

    //colorSettingsView
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"colorSettingsView"] == nil) //secondary
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @44 ,  @"red"   ,
                                                                                                    @44 ,  @"green" ,
                                                                                                    @44 ,  @"blue"  ,
                                                                                                    @1.0, @"alpha", nil]
                                              forKey:@"colorSettingsView"];
    
    //colorViewCollection
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"colorViewTitleCollection"] == nil) //transparancy
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @75 ,  @"red"   ,
                                                      @75 ,  @"green" ,
                                                      @75 ,  @"blue"  ,
                                                      @0.7, @"alpha",nil]
                                              forKey:@"colorViewTitleCollection"];
    
    
    
    //colorButtons
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"colorButtons"] == nil) //secondary
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @44 ,  @"red"   ,
                                                                                                    @44 ,  @"green" ,
                                                                                                    @44 ,  @"blue"  ,
                                                                                                    @1.0, @"alpha",nil]
                                              forKey:@"colorButtons"]; //modifiy good files for alpha  !
    
    
    
    //ColorLabelCollections
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"colorLabelCollections"] == nil) //primary
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @255 ,  @"red"   ,
                                                                                                    @255 ,  @"green" ,
                                                                                                    @255 ,  @"blue"  ,
                                                                                                    @1.0, @"alpha",nil]
                                              forKey:@"colorLabelCollections"];
  
    //backgroundColor
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @235 ,  @"red"   ,
                                                                                                    @235 ,  @"green" ,
                                                                                                    @235 ,  @"blue"  ,
                                                                                                    @1.0 ,  @"alpha", nil]
                                              forKey:@"backgroundColor"];
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [AppDelegate setAppearance];
    [self setParse];
    [self setNotificationsWithApplication:application];
    
    [NSTimer scheduledTimerWithTimeInterval:30.0
                                     target:self
                                   selector:@selector(fetchSettingsFromServer)
                                   userInfo:nil
                                    repeats:YES];

    return YES;
}

-(void) setParse{
    [Parse setApplicationId:@"iuIKM3lp6AQ4pjbUUhBAbvmju9BkH7UbtUVuauio"
                  clientKey:@"OhqF9MJOYvXwghJ7j5reJ46SIGyJG5mlwwy4O2qT"];
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

+(void) setAppearance{
    [[UINavigationBar appearance] setBarTintColor:
     [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"red"] floatValue] / 255
                     green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"green"] floatValue] / 255
                      blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"blue"] floatValue] / 255
                     alpha:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"alpha"] floatValue]]];
    
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

#pragma mark - refresh phone settings

-(void) fetchSettingsFromServer{
    [Store fetchSettingsFromServerAndForceShopifyUpdate:NO];
}


@end
