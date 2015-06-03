//
//  MOONAnalytics.m
//  Mooncode
//
//  Created by amaury soviche on 03/06/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "MOONAnalytics.h"

@interface MOONAnalytics ()

@end

@implementation MOONAnalytics

+ (instancetype)sharedManager {
    static MOONAnalytics *_sharedManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      _sharedManager = [[MOONAnalytics alloc] init];
    });

    return _sharedManager;
}

-(void)sendAnalyticsForVisitedCollectionWithId:(NSString*)collectionId {
    
    NSString *url = @"https://mooncode.herokuapp.com/app_activities";
    NSString *version = @"0";
    NSString *password = @"sanfrancisco";
    NSString *shopName = [[[NSUserDefaults standardUserDefaults] objectForKey:@"website_url"] stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    NSString *shopType = [[NSUserDefaults standardUserDefaults] objectForKey:@"shopType"];
    NSString *UDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];  //save it for analytics
    NSString *appAction = @"viewCollection";
    
    NSString *parameters = [NSString stringWithFormat:@"udid=%@&shopName=%@&shopType=%@&password=%@&version=%@&app_action=%@&app_location=%@", UDID, shopName, shopType, password, version, appAction, collectionId];
    
    NSData *postData = [parameters dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:nil];
}







@end
