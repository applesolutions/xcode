//
//  TabBarController.m
//  Mooncode
//
//  Created by amaury soviche on 31/05/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "TabBarController.h"

#import "SettingsViewController.h"
#import "CartViewController.h"
#import "SBInstagramController.h"

@interface TabBarController ()

@property(strong, nonatomic) SBInstagramController *instagram;

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //    self.tabBar.translucent = NO; // set NO -> cuts the view

    self.tabBar.tintColor = [UIColor whiteColor];

    CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 49);
    UIView *v = [[UIView alloc] initWithFrame:frame];
    v.tag = 500;
    [v setBackgroundColor:[self colorFromMemoryWithName:@"colorNavBar"]];
    [[self tabBar] addSubview:v];

    //set the images of tab bar items

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(instagramTokenChanged)
                                                 name:@"instagramTokenChanged"
                                               object:nil];

    //change the colors
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePhoneSettings)
                                                 name:@"updatePhoneSettings"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cartUpdated)
                                                 name:@"cartUpdated"
                                               object:nil];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard_autolayout" bundle:nil];

    SettingsViewController *settingsVC = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    UITabBarItem *settingsItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"nav-icon-settings"] tag:0];
    settingsVC.tabBarItem = settingsItem;

    UINavigationController *navController = [sb instantiateViewControllerWithIdentifier:@"NavControllerViewController"];
    UITabBarItem *collectionsItem = [[UITabBarItem alloc] initWithTitle:@"Collections" image:[UIImage imageNamed:@"nav-icon-collections"] tag:0];
    navController.tabBarItem = collectionsItem;

    CartViewController *cartVC = [sb instantiateViewControllerWithIdentifier:@"CartViewController"];
    
    NSData *dataFromMemory = [[NSUserDefaults standardUserDefaults] dataForKey:@"arrayProductsInCart"];
    NSString*imageName = [[NSKeyedUnarchiver unarchiveObjectWithData:dataFromMemory] count] == 0 ? @"nav-icon-cart" : @"nav-icon-cart-full";
    
    UITabBarItem *cartItem = [[UITabBarItem alloc] initWithTitle:@"Cart" image:[UIImage imageNamed:imageName] tag:0];

    cartVC.tabBarItem = cartItem;
    

    self.instagram = [SBInstagramController instagram];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isInstagramIntegrated"] == YES) {
        //INSTAGRAM *********************************************************************************************

        // WARNING : IF WE CHANGE THE KEYS HERE, ALSO CHANGE THE KEYS IN THE "InstagramKit" PLIST FILE !!!

        //setting up, data were taken from instagram app setting (www.instagram.com/developer)
        self.instagram.instagramRedirectUri = @"http://www.moonco.de";
        self.instagram.instagramClientSecret = @"056cacccca974d41a48001ba8cf619ee";
        self.instagram.instagramClientId = @"b5f5835cc8d04a5489a81df5c0654ca4";
        self.instagram.instagramDefaultAccessToken = @"1599947575.b5f5835.7379d52a27584ae78479ae466a2c368b";
        //            instagram.instagramUserId = @"447214845";
        //        instagram.instagramMultipleUsersId = @[@"447214845"];
        self.instagram.instagramMultipleUsersId = [[NSUserDefaults standardUserDefaults] objectForKey:@"instagramId"];

        //    instagram.instagramMultipleTags = @[@"sea",@"ground",@"fire"];

        //both are optional, but if you need search by tag you need set both
        //    instagram.isSearchByTag = YES; //if you want serach by tag
        //    instagram.searchTag = @"colombia"; //search by tag query

        self.instagram.showOnePicturePerRow = YES;  //to change way to show the feed, one picture per row(default = NO)
        self.instagram.showSwitchModeView = NO;     //show a segment controller with view option

        self.instagram.loadingImageName = @"SBInstagramLoading";  //config a custom loading image
        self.instagram.videoPlayImageName = @"SBInsta_play";
        self.instagram.videoPauseImageName = @"SBInsta_pause";
        //    instagram.playStandardResolution = YES; //if you want play a regular resuluton, low resolution per default

        [self.instagram refreshCollection];  //refresh instagram feed

        //*******************************************************************************************************
    }

    NSArray *arrayVC;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isInstagramIntegrated"] == YES) {
        arrayVC = [NSArray arrayWithObjects:settingsVC, navController, self.instagram.feed, cartVC, nil];
    } else {
        arrayVC = [NSArray arrayWithObjects:settingsVC, navController, cartVC, nil];
    }

    [self setViewControllers:arrayVC animated:YES];
    [self setSelectedIndex:1];
}

- (void)instagramTokenChanged {
    self.instagram.instagramMultipleUsersId = [[NSUserDefaults standardUserDefaults] objectForKey:@"instagramId"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateInstagramFeed" object:nil];
}

- (void)updatePhoneSettings {
    //change the color of the tabBar

    dispatch_async(dispatch_get_main_queue(), ^{

      for (UIView *subV in self.tabBar.subviews) {
          if (subV.tag == 500) {
              subV.backgroundColor = [self colorFromMemoryWithName:@"colorNavBar"];
          }
      }
    });

    //    [self colorFromMemoryWithName:@"colorNavBar"];
}

-(void)cartUpdated{
    
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController isKindOfClass:[CartViewController class]]) {
            UITabBarItem *tabItem = viewController.tabBarItem;
            
            NSData *dataFromMemory = [[NSUserDefaults standardUserDefaults] dataForKey:@"arrayProductsInCart"];
            NSString*imageName = [[NSKeyedUnarchiver unarchiveObjectWithData:dataFromMemory] count] == 0 ? @"nav-icon-cart" : @"nav-icon-cart-full";
            dispatch_async(dispatch_get_main_queue(), ^{
                tabItem.image = [UIImage imageNamed:imageName];
            });
        }
    }
    
}

- (UIColor *)colorFromMemoryWithName:(NSString *)colorName {
    return [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:colorName] objectForKey:@"red"] floatValue] / 255
                           green:[[[[NSUserDefaults standardUserDefaults] objectForKey:colorName] objectForKey:@"green"] floatValue] / 255
                            blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:colorName] objectForKey:@"blue"] floatValue] / 255
                           alpha:[[[[NSUserDefaults standardUserDefaults] objectForKey:colorName] objectForKey:@"alpha"] floatValue]];
}
@end
