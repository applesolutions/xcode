//
//  SettingsViewController.m
//  208
//
//  Created by amaury soviche on 14/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "SettingsViewController.h"


//send email
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ScrollViewController.h"

#import "SocialMedias.h"


@interface SettingsViewController ()
@property (nonatomic, strong) ScrollViewController *stlmMainViewController;

@property (strong, nonatomic) IBOutlet UIImageView *iconSettings;
@property (strong, nonatomic) IBOutlet UIButton *buttonRight;
@property (strong, nonatomic) IBOutlet UIButton *buttonTwitter;

@property (strong, nonatomic) IBOutlet UIImageView *imageMadeWithLove;

@property (strong, nonatomic) IBOutlet UILabel *LabelVersion;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor =
    [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorSettingsView"] objectForKey:@"red"] floatValue] / 255
                    green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorSettingsView"] objectForKey:@"green"] floatValue] / 255
                     blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorSettingsView"] objectForKey:@"blue"] floatValue] / 255
                    alpha:1];
    
    self.LabelVersion.text = [[[NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]] componentsSeparatedByString:@" "] objectAtIndex:1];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goRight:(id)sender {
    //access the parent view controller
    self.stlmMainViewController= (ScrollViewController *) self.parentViewController;
    [self.stlmMainViewController pageRight];
}

- (IBAction)tweet:(UIButton *)sender {

    [SocialMedias tweetWithMessage:[NSString stringWithFormat:@"Amazing products & app from @%@. Download it !", [[NSUserDefaults standardUserDefaults]objectForKey:@"twitterName"]]
                             image:nil
                               url:nil
                    viewController:self];
}

#pragma mark send mail
- (IBAction)ActionContactUs:(id)sender {
    
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        mailCont.navigationBar.translucent = NO;
        [mailCont.navigationBar setTintColor:[UIColor whiteColor]];
        
        
        mailCont.navigationBar.topItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
        
        [mailCont setSubject:@"Support - feedback"];
        [mailCont setToRecipients:[NSArray arrayWithObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"supportUrl"]]];
        
        
        [self presentModalViewController:mailCont animated:YES];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end