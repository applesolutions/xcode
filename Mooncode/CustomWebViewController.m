//
//  CustomWebViewController.m
//  Mooncode
//
//  Created by amaury soviche on 19/06/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "CustomWebViewController.h"
#import "UIColor+Custom.h"

@interface CustomWebViewController()<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UIView *ViewNavBar;

@end

@implementation CustomWebViewController

-(void)viewDidLoad{
    
    self.ViewNavBar.backgroundColor = [UIColor colorFromMemoryNamed:@"colorNavBar"];
    
    NSMutableURLRequest *request_cart = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://applesolutions.dk/apps/tracktor/track"]];
    [self.webView loadRequest:request_cart];
    
    self.webView.delegate=self;
    self.webView.hidden = YES;
    self.activity.hidden = NO;
    [self.activity startAnimating];
    [self.view addSubview:self.activity];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    self.activity.hidden=YES;
    [self.activity stopAnimating];
    self.webView.hidden = NO;
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
