//
//  ShopifyImages.m
//  Mooncode
//
//  Created by amaury soviche on 07/01/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "ShopifyImages.h"

@implementation ShopifyImages

+(void) checkIfImageHasBeenUpdatedWithProductId:(NSString*)productId{
    //ask for the published collections
    NSString *string_url =  [NSString stringWithFormat:@"%@/admin/products/%@/images.json", [[NSUserDefaults standardUserDefaults] objectForKey:@"website_url"], productId];
    
    NSLog(@"complete url : %@", string_url);
    NSURL *url = [NSURL URLWithString:string_url];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"shopify_token"]  forHTTPHeaderField:@"X-Shopify-Access-Token"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if (!error){
            
            NSDictionary* dicFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            NSLog(@"checkIfImageHasBeenUpdatedWithProductId  : %@", [dicFromServer description]);
        }
    }];
}

@end
