//
//  SocialMedias.m
//  208
//
//  Created by amaury soviche on 10/12/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "SocialMedias.h"

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>



@implementation SocialMedias

+(void)tweetWithMessage : (NSString*)twitterMessage image:(UIImage*) image url:(NSURL*)url viewController : (UIViewController*)UIViewController{
   
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        if(twitterMessage)
            [tweetSheet setInitialText:twitterMessage];
        
        if(image)
            [tweetSheet addImage:image];
        
        if(url)
            [tweetSheet addURL:url];
        

        [UIViewController presentViewController:tweetSheet animated:YES completion:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


@end
