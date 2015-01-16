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

//@property (strong,nonatomic) SettingsViewController *vc0;
@property (strong,nonatomic) NavControllerViewController *vc1;

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
    

    
    SBInstagramController *instagram = [SBInstagramController instagram];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isInstagramIntegrated"] == YES) {
        
        //INSTAGRAM *********************************************************************************************
        
        //here create the instagram view
        
        
        // WARNING : IF WE CHANGE THE KEYS HERE, ALSO CHANGE THE KEYS IN THE "InstagramKit" PLIST FILE !!!
        
        //setting up, data were taken from instagram app setting (www.instagram.com/developer)
        instagram.instagramRedirectUri = @"http://www.santiagobustamante.info";
        instagram.instagramClientSecret = @"dd9f687e1ffb4ff48ebc77188a14d283";
        instagram.instagramClientId = @"436eb0b4692245c899091391eaa5cdf1";
        instagram.instagramDefaultAccessToken = @"6874212.436eb0b.9768fd326f9b423eab7dd260972ee6db";
        //    instagram.instagramUserId = @"447214845";
        instagram.instagramMultipleUsersId = @[@"447214845"];
        //    instagram.instagramMultipleTags = @[@"sea",@"ground",@"fire"];
        
        //both are optional, but if you need search by tag you need set both
        //    instagram.isSearchByTag = YES; //if you want serach by tag
        //    instagram.searchTag = @"colombia"; //search by tag query
        
        instagram.showOnePicturePerRow = YES; //to change way to show the feed, one picture per row(default = NO)
        instagram.showSwitchModeView = NO; //show a segment controller with view option
        
        instagram.loadingImageName = @"SBInstagramLoading"; //config a custom loading image
        instagram.videoPlayImageName = @"SBInsta_play";
        instagram.videoPauseImageName = @"SBInsta_pause";
        //    instagram.playStandardResolution = YES; //if you want play a regular resuluton, low resolution per default
        
        [instagram refreshCollection]; //refresh instagram feed
        
        //*******************************************************************************************************
    }
    
    
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard_autolayout"
                                                  bundle:nil];
    
    //VIEW0
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isInstagramIntegrated"] == YES) {
        
        UINavigationController *navInstagram = [[UINavigationController alloc] initWithRootViewController:instagram.feed];
        self.vc0 = navInstagram;
    }else{
        UINavigationController *navSettings = [[UINavigationController alloc]
                                          initWithRootViewController:[sb instantiateViewControllerWithIdentifier:@"SettingsViewController"]];
        
        self.vc0 = navSettings;
    }
//    self.vc0 = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
    [self addChildViewController:self.vc0];
    [self.scrollView addSubview:self.vc0.view];
    [self.vc0 didMoveToParentViewController:self];
    
    
    
    //VIEW1
    self.vc1 = [sb instantiateViewControllerWithIdentifier:@"NavControllerViewController"];
    //    CGRect frame1 = self.vc1.view.frame;
    //    frame1.origin.x = 320;
    //    self.vc1.view.frame = frame1;
    
    [self addChildViewController:self.vc1];
    [self.scrollView addSubview:self.vc1.view];
    [self.vc1 didMoveToParentViewController:self];
    
    
    
    CGPoint cgPoint = CGPointMake(self.view.frame.size.width, 0);
    
    self.scrollView.contentSize = CGSizeMake(2*self.view.frame.size.width, self.view.frame.size.height);
    [self.scrollView setContentOffset:cgPoint animated:NO];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.bounces=NO;
    
    
    
    
    // AUTOLAYOUT ******************************************************************************************
    
    
    self.vc1.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.vc0.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    NSDictionary *viewsDictionary = @{@"vc1":self.vc1.view,
                                      @"vc0":self.vc0.view};
    
    NSString *width = [NSString stringWithFormat:@"%f", self.view.frame.size.width];
    NSString *height = [NSString stringWithFormat:@"%f", self.view.frame.size.height];
    
    NSLog(@"height : %@ and width : %@", height, width);
    
    
    
    NSArray *constraint_H_vc0 = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"V:[vc0(%@)]", height]
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    NSArray *constraint_V_vc0 = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"H:[vc0(%@)]", width]
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    [self.vc0.view addConstraints:constraint_V_vc0];
    [self.vc0.view addConstraints:constraint_H_vc0];
    
    
    
    
    
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
    
    
    
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"H:|-%@-[vc1]", width]
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    NSArray *constraint_POS_H_2 = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-0-[vc1]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary];
    
    
    
    NSArray *constraint_POS_H_vc0 = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-0-[vc0]"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary];
    NSArray *constraint_POS_H_vc0_2 = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-0-[vc0]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    
    
    
    
    
    
    
    [self.view addConstraints:constraint_POS_H];
    [self.view addConstraints:constraint_POS_H_2];
    [self.view addConstraints:constraint_POS_H_vc0];
    [self.view addConstraints:constraint_POS_H_vc0_2];
    
    
    
}

-(void) viewDidAppear:(BOOL)animated{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    if (sender.contentOffset.x < 0) {
        sender.contentOffset = CGPointMake(0, sender.contentOffset.y);
    }
    
    if (sender.contentOffset.x > self.view.frame.size.width) {
        sender.contentOffset = CGPointMake(self.view.frame.size.width, sender.contentOffset.y);
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

@end
