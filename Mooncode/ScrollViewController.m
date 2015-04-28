//
//  ScrollViewController.m
//  QRCodeReader
//
//  Created by amaury soviche on 18/05/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "ScrollViewController.h"

#import "SettingsViewController.h"
#import "CategoriesViewController.h"

#import "NavControllerViewController.h"

#import "SBInstagramImageViewController.h"

#import "SBInstagramController.h"

@interface ScrollViewController ()

@property (strong,nonatomic) UINavigationController *vc0;
@property (strong,nonatomic) SettingsViewController *VCsettings;
@property (strong,nonatomic) NavControllerViewController *vc1;
@property (strong, nonatomic) SBInstagramController *instagram;

@end

@implementation ScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    
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
        
        self.instagram.showOnePicturePerRow = YES; //to change way to show the feed, one picture per row(default = NO)
        self.instagram.showSwitchModeView = NO; //show a segment controller with view option
        
        self.instagram.loadingImageName = @"SBInstagramLoading"; //config a custom loading image
        self.instagram.videoPlayImageName = @"SBInsta_play";
        self.instagram.videoPauseImageName = @"SBInsta_pause";
        //    instagram.playStandardResolution = YES; //if you want play a regular resuluton, low resolution per default
        
        [self.instagram refreshCollection]; //refresh instagram feed
        
        //*******************************************************************************************************
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(instagramTokenChanged)
                                                 name:@"instagramTokenChanged"
                                               object:nil];
    
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard_autolayout"
                                                  bundle:nil];
    
    //VIEW SETTINGS
    self.VCsettings = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    //    CGRect frame1 = self.vc1.view.frame;
    //    frame1.origin.x = 320;
    //    self.vc1.view.frame = frame1;
    
    [self addChildViewController:self.VCsettings];
    [self.scrollView addSubview:self.VCsettings.view];
    [self.VCsettings didMoveToParentViewController:self];
    
    //VIEW INSTAGRAM
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isInstagramIntegrated"] == YES) {
        
        UINavigationController *navInstagram = [[UINavigationController alloc] initWithRootViewController:self.instagram.feed];
        self.vc0 = navInstagram;
        
        [self addChildViewController:self.vc0];
        [self.scrollView addSubview:self.vc0.view];
        [self.vc0 didMoveToParentViewController:self];
    }
    
    //VIEW COLLECTIONS
    self.vc1 = [sb instantiateViewControllerWithIdentifier:@"NavControllerViewController"];
    
    [self addChildViewController:self.vc1];
    [self.scrollView addSubview:self.vc1.view];
    [self.vc1 didMoveToParentViewController:self];
    
    
    
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isInstagramIntegrated"] == YES) {
        CGPoint cgPoint = CGPointMake(2*self.view.frame.size.width, 0);
        self.scrollView.contentSize = CGSizeMake(3*self.view.frame.size.width, self.view.frame.size.height);
        [self.scrollView setContentOffset:cgPoint animated:NO];
    }else{
        CGPoint cgPoint = CGPointMake(self.view.frame.size.width, 0);
        self.scrollView.contentSize = CGSizeMake(2*self.view.frame.size.width, self.view.frame.size.height);
        [self.scrollView setContentOffset:cgPoint animated:NO];
    }

    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.bounces=NO;
    
    
    
    
    // AUTOLAYOUT ******************************************************************************************
    
    
    self.vc1.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.vc0.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.VCsettings.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *viewsDictionary;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isInstagramIntegrated"] == YES) {
        viewsDictionary = @{@"vc1":self.vc1.view,
                            @"vc0":self.vc0.view,
                            @"VCSettings": self.VCsettings.view};
    }else{
        viewsDictionary = @{@"vc1":self.vc1.view,
                            @"VCSettings": self.VCsettings.view};
    }
    
    
    NSString *width = [NSString stringWithFormat:@"%f", self.view.frame.size.width];
    NSString *doubleWidth = [NSString stringWithFormat:@"%f", 2*self.view.frame.size.width];
    NSString *height = [NSString stringWithFormat:@"%f", self.view.frame.size.height];
    
    NSLog(@"height : %@ and width : %@", height, width);
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isInstagramIntegrated"] == YES) {
        
        NSArray *constraint_V_vc0 = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"V:[vc0(%@)]", height]
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary];
        
        NSArray *constraint_H_vc0 = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"H:[vc0(%@)]", width]
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary];
        
        [self.vc0.view addConstraints:constraint_V_vc0];
        [self.vc0.view addConstraints:constraint_H_vc0];
    }
    
    
    
    
    
    NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"V:[vc1(%@)]", height]
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDictionary];
    
    NSArray *constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"H:[vc1(%@)]", width]
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDictionary];
    
    
    [self.vc1.view addConstraints:constraint_V];
    [self.vc1.view addConstraints:constraint_H];
    
    
    
    NSArray *constraint_H_settings = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"V:[VCSettings(%@)]", height]
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    NSArray *constraint_V_settings = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"H:[VCSettings(%@)]", width]
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    
    [self.VCsettings.view addConstraints:constraint_H_settings];
    [self.VCsettings.view addConstraints:constraint_V_settings];
    
    
    
    
    
    
    //*****************
    
    
    
    
    
    
    NSArray *constraint_POS_H_VCSettings = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-0-[VCSettings]"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:viewsDictionary];
    NSArray *constraint_POS_V_VCSettings = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-0-[VCSettings]"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:viewsDictionary];
    [self.view addConstraints:constraint_POS_H_VCSettings];
    [self.view addConstraints:constraint_POS_V_VCSettings];
    
    
    NSString *space;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isInstagramIntegrated"] == YES) {
        space = doubleWidth;
    }else{
        space = width;
    }
    
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"H:|-%@-[vc1]", space]
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    NSArray *constraint_POS_H_2 = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-0-[vc1]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isInstagramIntegrated"] == YES) {
        
        NSArray *constraint_POS_H_Instagram = [NSLayoutConstraint constraintsWithVisualFormat: [NSString stringWithFormat: @"H:|-%@-[vc0]", width]
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:viewsDictionary];
        
        NSArray *constraint_POS_V_Instagram = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-0-[vc0]"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:viewsDictionary];
        [self.view addConstraints:constraint_POS_H_Instagram];
        [self.view addConstraints:constraint_POS_V_Instagram];
        
    }
    
    
    [self.view addConstraints:constraint_POS_H];
    [self.view addConstraints:constraint_POS_H_2];
    
}

-(void) viewDidAppear:(BOOL)animated{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    int isInstagram = 1;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isInstagramIntegrated"] == YES) {
        isInstagram = 2;
    }
    
    if (sender.contentOffset.x < 0) {
        sender.contentOffset = CGPointMake(0, sender.contentOffset.y);
    }
    
    if (sender.contentOffset.x > isInstagram * self.view.frame.size.width) {
        sender.contentOffset = CGPointMake(isInstagram * self.view.frame.size.width, sender.contentOffset.y);
    }
    
}

-(void) pageLeft{
    CGRect frame = self.scrollView.frame;
    //    frame.origin.x = 0;
    frame.origin.x = self.scrollView.contentOffset.x - self.view.frame.size.width ;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

-(void) pageRight{
    CGRect frame = self.scrollView.frame;
    frame.origin.x = self.scrollView.contentOffset.x + self.view.frame.size.width ;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

-(void) enableScrollView{
    
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled=YES;
}

-(void) disableScrollView {
    NSLog(@"alllllo");
    self.scrollView.scrollEnabled = NO;
    self.scrollView.pagingEnabled = NO;
}

-(void)instagramTokenChanged{
    self.instagram.instagramMultipleUsersId = [[NSUserDefaults standardUserDefaults] objectForKey:@"instagramId"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateInstagramFeed" object:nil];
}

@end
