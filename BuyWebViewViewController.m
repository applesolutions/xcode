//
//  BuyWebViewViewController.m
//  208
//
//  Created by amaury soviche on 25/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "BuyWebViewViewController.h"

@interface BuyWebViewViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (strong, nonatomic) IBOutlet UIView *ViewNavBar;
@end

@implementation BuyWebViewViewController{
    
    NSString *website_cart;
}

-(void) viewWillAppear:(BOOL)animated{
    
    self.ViewNavBar.backgroundColor =
    [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"red"] floatValue] / 255
                    green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"green"] floatValue] / 255
                     blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"blue"] floatValue] / 255
                    alpha:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    website_cart = [[NSUserDefaults standardUserDefaults] objectForKey:@"website_cart_url"];
    
    self.webView.delegate=self;
    self.webView.hidden = YES;
    self.activity.hidden = NO;
    [self.activity startAnimating];
    [self.view addSubview:self.activity];
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/cart/clear.js",website_cart]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.timeoutInterval = 15;
    [request setURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if (error.code == -1001 || error.code == -1009) {
            NSLog(@"error: %@", [error description]);
            
            //error label : you might be ofline...
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UILabel *labelError = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 60)];
                labelError.center = self.view.center;
                labelError.adjustsFontSizeToFitWidth = YES;
                labelError.font = [UIFont fontWithName:@"ProximaNova-SemiBold" size:17.0f];
                labelError.textAlignment = UITextAlignmentCenter;
                labelError.numberOfLines = 3;
                labelError.text = @"There is a problem with your internet connection.\nPlease reconnect to the internet or try later.";
                [self.view addSubview:labelError];
                self.webView.hidden = YES;
                self.activity.hidden = YES;
                [self.activity stopAnimating];
                
            });
            
        }else{
            
            [self makeRequestToAddToCart:[self.arrayProductsInCart firstObject] atIndex:0];
        }
    }];
}

-(void) makeRequestToAddToCart:(NSDictionary*) dicObject atIndex : (int) index {
    //    NSLog(@"dic to send request : %@", [dicObject description]);
    
//    NSDictionary *dicVariant = [dicObject objectForKey:@"dicVariant"];
    
    NSURL *url_add_product_To_cart = [NSURL URLWithString:[website_cart stringByAppendingString:@"/cart/add.js"]];
//    NSString *body = [NSString stringWithFormat: @"quantity=%@&id=%@", [dicObject objectForKey:@"qte"],[dicVariant objectForKey:@"id"]];
    NSString *body = [NSString stringWithFormat: @"quantity=%@&id=%@", [dicObject objectForKey:@"qte"],[[dicObject objectForKey:@"dicVariant"] objectForKey:@"id"]];

    
    //    NSLog(@"url with product : %@",body );
    NSMutableURLRequest *request_add_product_To_cart  = [[NSMutableURLRequest alloc]initWithURL: url_add_product_To_cart];
    [request_add_product_To_cart setHTTPMethod: @"POST"];
    [request_add_product_To_cart setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request_add_product_To_cart queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        //        NSDictionary* dicFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        //        NSLog(@"response for loop : %@", dicFromServer);
        
        if (index != [self.arrayProductsInCart count]-1) {
            
            [self makeRequestToAddToCart:[self.arrayProductsInCart objectAtIndex:(index+1)] atIndex:(index+1)];
        }else{

            NSMutableURLRequest *request_cart = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[website_cart stringByAppendingString:@"/checkout"]]];
            [self.webView loadRequest:request_cart];
        }
    }];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSLog(@"webViewDidFinishLoad with url : %@", webView.request.URL.absoluteString);
    
    if (webView.isLoading) {
        return;
    }
    
    if ([webView.request.URL.absoluteString hasPrefix:[[NSUserDefaults standardUserDefaults] objectForKey:@"checkoutUrl"]]) {
        
        self.activity.hidden=YES;
        [self.activity stopAnimating];
        self.webView.hidden = NO;
    }
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *currentURL = request.URL.absoluteString;
    NSLog(@"shouldStartLoadWithRequest with url : %@", currentURL);
    return YES;
}

@end
