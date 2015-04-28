//
//    Copyright (c) 2013 Shyam Bhat
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of
//    this software and associated documentation files (the "Software"), to deal in
//    the Software without restriction, including without limitation the rights to
//    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//    the Software, and to permit persons to whom the Software is furnished to do so,
//    subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "IKLoginViewController.h"


@implementation IKLoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ViewNavBar.backgroundColor =
    [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"red"] floatValue] / 255
                    green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"green"] floatValue] / 255
                     blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"blue"] floatValue] / 255
                    alpha:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"alpha"] floatValue] ];
    
    [self.activity startAnimating];
    self.activity.color = self.ViewNavBar.backgroundColor;

    
    mWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    mWebView.scrollView.bounces = NO;
    mWebView.contentMode = UIViewContentModeScaleAspectFit;
    mWebView.delegate = self;
    
    self.scope = IKLoginScopeRelationships | IKLoginScopeComments | IKLoginScopeLikes;
    
    NSDictionary *configuration = [InstagramEngine sharedEngineConfiguration];
    NSString *scopeString = [InstagramEngine stringForScope:self.scope];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@", configuration[kInstagramKitAuthorizationUrlConfigurationKey], configuration[kInstagramKitAppClientIdConfigurationKey], configuration[kInstagramKitAppRedirectUrlConfigurationKey], scopeString]];

    [mWebView loadRequest:[NSURLRequest requestWithURL:url]];
    

}

- (IBAction)back:(UIBarButtonItem*)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *URLString = [request.URL absoluteString];
   
    if ([URLString hasPrefix:[[InstagramEngine sharedEngine] appRedirectURL]]) {
        NSString *delimiter = @"access_token=";
        NSArray *components = [URLString componentsSeparatedByString:delimiter];
       
        if (components.count > 1) {
           
            NSString *accessToken = [components lastObject];
            NSLog(@"ACCESS TOKEN = %@",accessToken);
            [[InstagramEngine sharedEngine] setAccessToken:accessToken];
            
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isUserLoggedIn"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self dismissViewControllerAnimated:YES completion:^{
                NSLog(@"url to open : %@", self.urlForMedia);
                [self.instagramCollectionViewController presentMediaWebViewControllerWithUrl:self.urlForMedia];
            }];
        }
        return NO;
    }
    return YES;
}

-(void) webViewDidFinishLoad:(UIWebView *)webView{
    [self.activity stopAnimating];
    self.activity.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}



@end
