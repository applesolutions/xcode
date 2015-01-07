//
//  SocialMedias.h
//  208
//
//  Created by amaury soviche on 10/12/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SocialMedias : NSObject

+(void)tweetWithMessage : (NSString*)twitterMessage image:(UIImage*) image url:(NSURL*)url viewController : (UIViewController*)UIViewController;


@end
