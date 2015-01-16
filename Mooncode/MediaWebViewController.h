//
//  MediaWebViewController.h
//  Mooncode
//
//  Created by amaury soviche on 13/01/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaWebViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, strong) NSURL *urlForMedia;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;


@end
