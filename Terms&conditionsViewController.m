//
//  Terms&conditionsViewController.m
//  208
//
//  Created by amaury soviche on 28/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "Terms&conditionsViewController.h"

@interface Terms_conditionsViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@end

@implementation Terms_conditionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    
    NSURL * url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"urlForTerms"]];
    

    //load webView
    self.webView.delegate=self;
    
    self.webView.hidden = NO;
    self.activity.hidden = NO;
    
    [self.activity startAnimating];
    self.activity.center = self.webView.center;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [self.webView loadRequest: request];

}



- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activity stopAnimating];
    self.activity.hidden = YES;
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.activity stopAnimating];
    self.activity.hidden = YES;
    
    NSLog(@"error : %@", [error description]);
}
@end
