//
//  SettingsViewController.m
//  208
//
//  Created by amaury soviche on 14/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "SettingsViewController.h"
#import "SocialMedias.h"


@interface SettingsViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *iconSettings;
@property (strong, nonatomic) IBOutlet UIButton *buttonRight;
@property (strong, nonatomic) IBOutlet UIButton *buttonTwitter;

@property (strong, nonatomic) IBOutlet UIImageView *imageMadeWithLove;

@property (strong, nonatomic) IBOutlet UILabel *LabelVersion;

//constraints

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraint_delta_middleView;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        self.constraint_delta_middleView.constant = 150;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateColors)
                                                 name:@"updatePhoneSettings"
                                               object:nil];

    [self updateColors];
    
    self.LabelVersion.text = [[[NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]] componentsSeparatedByString:@" "] objectAtIndex:1];

}

-(void)updateColors{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.backgroundColor =
        [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorSettingsView"] objectForKey:@"red"] floatValue] / 255
                        green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorSettingsView"] objectForKey:@"green"] floatValue] / 255
                         blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorSettingsView"] objectForKey:@"blue"] floatValue] / 255
                        alpha:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorSettingsView"] objectForKey:@"alpha"] floatValue]];
    });

}

-(void) viewWillAppear:(BOOL)animated{
    //VIEW0

    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goRight:(id)sender {
    //access the parent view controller
}

- (IBAction)tweet:(UIButton *)sender {
    [SocialMedias shareOnTwitterForState:kMOONShareOnTwitterFromSettings image:nil url:nil viewController:self];
}

#pragma mark send mail
- (IBAction)ActionContactUs:(id)sender {
    
    if([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        mailCont.navigationBar.translucent = NO;
        [mailCont.navigationBar setTintColor:[UIColor whiteColor]];
        
//        mailCont.topViewController.navigationController
        
        [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                        NSForegroundColorAttributeName: [UIColor whiteColor],
                                                        NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Regular" size:19.0f],
                                                        }];
        
        [mailCont setSubject:@"Support - feedback"];
        [mailCont setToRecipients:[NSArray arrayWithObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"supportEmail"]]];
        
        [self presentViewController:mailCont animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
