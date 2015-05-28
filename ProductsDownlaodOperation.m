//
//  ProductsDownlaodOperation.m
//  Mooncode
//
//  Created by amaury soviche on 23/05/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "ProductsDownlaodOperation.h"

@implementation ProductsDownlaodOperation

- (id)initWithCollectionId:(NSString *)collectionId pageNumber:(int)pageNumber token:(NSString *)token completionBlock:(CompletionBlock)completionBlock {
    if (![super init]) return nil;

    _collectionId = collectionId;
    _pageNumber = pageNumber;
    _token = token;
    _block = completionBlock;

    return self;
}

- (void)main {
    NSString *website_string = [[NSUserDefaults standardUserDefaults] stringForKey:@"website_url"];
    NSString *string_url = [NSString stringWithFormat:@"%@/admin/products.json?published_status=published&collection_id=%@&page=%d&limit=250", website_string, self.collectionId, self.pageNumber];
    NSURL *url = [NSURL URLWithString:string_url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setValue:self.token forHTTPHeaderField:@"X-Shopify-Access-Token"];
    [request setURL:url];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                             if (self.block) {
                                 self.block(response, data, error, self.collectionId, self.pageNumber);
                             }

                           }];
}

@end
