//
//  MediaWebViewController.m
//  Mooncode
//
//  Created by amaury soviche on 13/01/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "MediaWebViewController.h"

@interface MediaWebViewController ()
@property (strong, nonatomic) IBOutlet UIView *ViewNavBar;
@end

@implementation MediaWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad : %@", self.urlForMedia);
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.urlForMedia]]]];
    
    self.ViewNavBar.backgroundColor =
    [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"red"] floatValue] / 255
                    green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"green"] floatValue] / 255
                     blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"blue"] floatValue] / 255
                    alpha:1];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView{
    
    NSLog(@"webViewDidFinishLoad ");
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"var cta = document.getElementsByClassName('top-cta'); cta[0].parentNode.removeChild(cta[0]);var header = document.getElementsByTagName('header'); header[0].parentNode.removeChild(header[0]); var footer = document.getElementsByTagName('footer'); footer[0].parentNode.removeChild(footer[0]);"];
}

@end
