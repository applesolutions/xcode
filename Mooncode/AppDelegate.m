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
#import "FCFileManager.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //DELETE EVERYTHING *******
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    //*************************
    
    [[NSUserDefaults standardUserDefaults] setObject:@"https://buyonesnap.myshopify.com" forKey:@"website_url"];

    [[NSUserDefaults standardUserDefaults] setObject:@"buyonesnap.myshopify.com" forKey:@"shopName"];
    [[NSUserDefaults standardUserDefaults] setObject:@"shopify" forKey:@"shopType"];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"http://fedbythreads.com" forKey:@"website_cart_url"];
    [[NSUserDefaults standardUserDefaults] setObject:@"info@fedbythreads.com" forKey:@"supportUrl"];
    [[NSUserDefaults standardUserDefaults] setObject:@"https://checkout.shopify.com" forKey:@"checkoutUrl"];
    [[NSUserDefaults standardUserDefaults] setObject:@"$" forKey:@"currency"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"areCollectionsDisplayed"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isInstagramIntegrated"];
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"instagramId"] == nil) { //298508107
        [[NSUserDefaults standardUserDefaults] setObject:@[@""] forKey:@"instagramId"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"twitterName"] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"FedByThreads" forKey:@"twitterName"];
    }
    
    
//    [Flurry startSession:@""];
    
    
    //colorNavBar
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] == nil) //secondary
        [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @172 ,  @"red"   ,
                                                                                                    @34 ,  @"green" ,
                                                                                                    @52 ,  @"blue"  ,
                                                                                                    @1.0, @"alpha", nil]
                                              forKey:@"colorNavBar"];

    //colorSettingsView
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"colorSettingsView"] == nil) //secondary
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @48 ,  @"red"   ,
                                                                                                    @48 ,  @"green" ,
                                                                                                    @48 ,  @"blue"  ,
                                                                                                    @1.0, @"alpha", nil]
                                              forKey:@"colorSettingsView"];
    
    //colorViewCollection
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"colorViewTitleCollection"] == nil) //transparancy
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @172 ,  @"red"   ,
                                                      @34 ,  @"green" ,
                                                      @52 ,  @"blue"  ,
                                                      @1.0, @"alpha",nil]
                                              forKey:@"colorViewTitleCollection"];
    
    
    
    //colorButtons
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"colorButtons"] == nil) //primary
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:    @156 ,  @"red"   ,
                                                                                                    @31 ,  @"green" ,
                                                                                                    @57 ,  @"blue"  ,
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
    
    NSString *urlForFiles = @"https://mooncode.herokuapp.com/shopify_merchant/settings";
    NSString *version = @"0";
    NSString *password = @"sanfrancisco";
    NSString *shopName = [[NSUserDefaults standardUserDefaults] objectForKey:@"shopName"];
    NSString *shopType = [[NSUserDefaults standardUserDefaults] objectForKey:@"shopType"];
    NSString *pathMainBundle = [[FCFileManager pathForDocumentsDirectory] stringByAppendingString:@"/"];
    pathMainBundle = @"";
    NSString *UDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; //save it for analytics
    
    
    NSString *parametersSettings = [NSString stringWithFormat:@"udid=%@&shopName=%@&shopType=%@&password=%@&version=%@&resourcesPath=%@&memoryPath=", UDID, shopName, shopType, password, version, pathMainBundle];
    
    NSLog(@"param view : %@", parametersSettings);
    [self test_POST_withUrl:urlForFiles andParameters:parametersSettings withPassword:password callback:^(NSDictionary *settings, NSError*error) {
        
        if (!error) {
            
            NSString *shopify_token = settings[@"shopify_token"];
            NSString *twitter = settings[@"twitter"];
            NSString *instagram = settings[@"instagram"];
            
            if (shopify_token){
//                token = shopify_token;
            }
            if (twitter) {
                [[NSUserDefaults standardUserDefaults] setObject:twitter forKey:@"twitterName"];
            }
            //            if (instagram && instagram.length != 0) {
            //                [[NSUserDefaults standardUserDefaults] setObject:instagram forKey:@"instagramId"];
            //            }
            
            //colors
            
            
            
            NSDictionary *dicColorMatching = @{@"primary":@[@"colorButtons",@"colorLabelCollections"],
                                               @"secondary":@[@"colorNavBar",@"colorSettingsView"],
                                               @"transparency":@[@"colorViewTitleCollection"]
                                               };
            
            NSDictionary *colorsFromServer = settings[@"colors"];
            
            
            
            [dicColorMatching enumerateKeysAndObjectsUsingBlock:^(NSString *colorNameServer, NSArray *colorsNamesUserDef, BOOL *stop) {
                
                
                
                
                NSDictionary *dicColorTranslated = @{
                                                     @"red" : @([colorsFromServer[colorNameServer][@"r"] integerValue]),
                                                     @"green" : @([colorsFromServer[colorNameServer][@"g"] integerValue]),
                                                     @"blue" : @([colorsFromServer[colorNameServer][@"b"] integerValue]),
                                                     @"alpha" : @([colorsFromServer[colorNameServer][@"a"] floatValue]),
                                                     };
                
                NSLog(@"dic translated for %@ : %@", colorNameServer, [dicColorTranslated description]);
                
                for (NSString *colorNameUserDef in colorsNamesUserDef) {
                    
                    [[NSUserDefaults standardUserDefaults] setObject:dicColorTranslated forKey:colorNameUserDef];
                }
                
                [[NSUserDefaults standardUserDefaults] synchronize];
            }];
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePhoneSettings" object:nil];
            
            
            
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            

            
        }
    }];
}


-(void) test_POST_withUrl:(NSString*)url  andParameters:(NSString*)parameters withPassword:(NSString*)password callback:(void (^)(NSDictionary*fileContent, NSError*error))giveFileContent{
    
    NSData *postData = [parameters dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if (!error){
            //added
            //            NSString* contentStringFile = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary* settings = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            NSLog(@"content of file test : %@", settings);
            giveFileContent(settings,nil);
            
            
        }else{
            
            giveFileContent(nil, error);
        }
    }];
}

@end
