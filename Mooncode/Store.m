//
//  Store.m
//  Mooncode
//
//  Created by amaury soviche on 23/04/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "Store.h"
#import "FCFileManager.h"
#import "NSUserDefaultsMethods.h"

@implementation Store

+ (void)fetchSettingsFromServerAndForceShopifyUpdate:(BOOL)forceShopifyUpdate {
    NSString *urlForFiles = @"https://mooncode.herokuapp.com/shopify_merchant/settings";
    NSString *version = @"0";
    NSString *password = @"sanfrancisco";
    NSString *shopName = [[[NSUserDefaults standardUserDefaults] objectForKey:@"website_url"] stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    NSString *shopType = [[NSUserDefaults standardUserDefaults] objectForKey:@"shopType"];
    NSString *pathMainBundle = [[FCFileManager pathForDocumentsDirectory] stringByAppendingString:@"/"];
    pathMainBundle = @"";
    NSString *UDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];  //save it for analytics

    NSString *parametersSettings = [NSString stringWithFormat:@"udid=%@&shopName=%@&shopType=%@&password=%@&version=%@&resourcesPath=%@&memoryPath=", UDID, shopName, shopType, password, version, pathMainBundle];

    //    NSLog(@"param view : %@", parametersSettings);
    [self test_POST_withUrl:urlForFiles
              andParameters:parametersSettings
               withPassword:password
                   callback:^(NSDictionary *settings, NSError *error) {

                     if (!error) {
                         NSLog(@"main th : %d", [NSThread isMainThread]);
                         
                         NSString *shopify_token = (NSString *)settings[@"shopify_token"];
                         NSString *twitter = (NSString *)settings[@"twitter"];
                         NSString *instagram = [settings[@"instagram_id"] stringValue];

                         NSArray *displayedCollectionsFromServer = settings[@"displayed_collections"];
                         NSArray *featuredCollectionsFromServer = settings[@"featured_collections"];
                         [NSUserDefaultsMethods saveObjectInMemory:displayedCollectionsFromServer toFolder:@"displayedCollections"];
                         [NSUserDefaultsMethods saveObjectInMemory:featuredCollectionsFromServer toFolder:@"featuredCollections"];

                         if (shopify_token) {
                             [[NSUserDefaults standardUserDefaults] setObject:shopify_token forKey:@"shopifyToken"];
                         }

                         NSMutableArray *arrayCustomCollectionsIds = [[NSMutableArray alloc] init];
                         for (NSDictionary *collection in displayedCollectionsFromServer) {
                             [arrayCustomCollectionsIds addObject:[collection[@"shopify_collection_id"] stringValue]];
                         }
                         [[NSUserDefaults standardUserDefaults] setObject:arrayCustomCollectionsIds forKey:@"arrayCustomCollectionsIds"];

                         if (twitter) {
                             twitter = [twitter stringByReplacingOccurrencesOfString:@"@" withString:@""];
                             [[NSUserDefaults standardUserDefaults] setObject:twitter forKey:@"twitterName"];
                         }

                         [[NSUserDefaults standardUserDefaults] synchronize];

                         if (instagram && instagram.length != 0) {
                             NSLog(@"instagram : %@", instagram);

                             if (![[[NSUserDefaults standardUserDefaults] arrayForKey:@"instagramId"].firstObject isEqualToString:instagram]) {
                                 [[NSUserDefaults standardUserDefaults] setObject:@[ [NSString stringWithFormat:@"%@", (NSString *)instagram] ] forKey:@"instagramId"];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"instagramTokenChanged" object:nil];  //observed in scrollViewController
                             }
                         }

                         //colors
                         NSDictionary *dicColorMatching = @{ @"primary" : @[ @"colorLabelCollections" ],
                                                             @"secondary" : @[ @"colorNavBar", @"colorSettingsView", @"colorButtons" ],
                                                             @"transparency" : @[ @"colorViewTitleCollection" ]
                         };

                         NSDictionary *colorsFromServer = settings[@"colors"];

                         [dicColorMatching enumerateKeysAndObjectsUsingBlock:^(NSString *colorNameServer, NSArray *colorsNamesUserDef, BOOL *stop) {

                           NSDictionary *dicColorTranslated = @{
                               @"red" : @([colorsFromServer[colorNameServer][@"r"] integerValue]),
                               @"green" : @([colorsFromServer[colorNameServer][@"g"] integerValue]),
                               @"blue" : @([colorsFromServer[colorNameServer][@"b"] integerValue]),
                               @"alpha" : @([colorsFromServer[colorNameServer][@"a"] floatValue]),
                           };

                           //                NSLog(@"dic translated for %@ : %@", colorNameServer, [dicColorTranslated description]);

                           for (NSString *colorNameUserDef in colorsNamesUserDef) {
                               [[NSUserDefaults standardUserDefaults] setObject:dicColorTranslated forKey:colorNameUserDef];
                           }
                           [[NSUserDefaults standardUserDefaults] synchronize];
                         }];

                         [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePhoneSettings"
                                                                             object:nil
                                                                           userInfo:@{ @"forceShopifyUpdate" : [NSNumber numberWithBool:forceShopifyUpdate] }];

                     } else {
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePhoneSettings"
                                                                             object:nil
                                                                           userInfo:@{ @"error" : error,
                                                                                       @"forceShopifyUpdate" : [NSNumber numberWithBool:forceShopifyUpdate] }];  //error : don't update shopify
                     }
                   }];
}

+ (void)test_POST_withUrl:(NSString *)url andParameters:(NSString *)parameters withPassword:(NSString *)password callback:(void (^)(NSDictionary *fileContent, NSError *error))giveFileContent {
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
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                             if (!error) {

                                 NSDictionary *settings = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

                                 if (settings != (id)[NSNull null] && [settings respondsToSelector:@selector(allKeys)]) {
                                     giveFileContent(settings, nil);
                                 } else {
                                     NSLog(@"it is null");
                                     giveFileContent(nil, [NSError errorWithDomain:@"error" code:101 userInfo:nil]);
                                 }

                             } else {
                                 giveFileContent(nil, error);
                             }
                           }];
}

@end
