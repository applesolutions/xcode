//
//  ProductsDownlaodOperation.m
//  Mooncode
//
//  Created by amaury soviche on 23/05/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "ProductsDownlaodOperation.h"

@interface ProductsDownlaodOperation ()

@property(assign) BOOL isExecuting;
@property(assign) BOOL isFinished;

@end

@implementation ProductsDownlaodOperation

@synthesize isExecuting, isFinished;

- (id)initWithCollectionId:(NSString *)collectionId pageNumber:(int)pageNumber token:(NSString *)token completionBlock:(CompletionBlock)completionBlock {
    if (![super init]) return nil;

    _collectionId = collectionId;
    _pageNumber = pageNumber;
    _token = token;
    _block = completionBlock;

    return self;
}

- (id)initWithCollectionId:(NSString *)collectionId token:(NSString *)token completionBlock:(CompletionBlock2)completionBlock2 {
    if (![super init]) return nil;

    _collectionId = collectionId;
    _pageNumber = 1;
    _token = token;
    _block2 = completionBlock2;

    return self;
}

- (id)initWithCollectionId:(NSString *)collectionId pageNumber:(int)pageNumber token:(NSString *)token downloadedCollections:(NSArray *)downloadedProducts completionBlock:(CompletionBlock2)completionBlock {
    if (![super init]) return nil;

    _collectionId = collectionId;
    _pageNumber = pageNumber;
    _token = token;
    _block2 = completionBlock;
    _downloadedProducts = downloadedProducts;

    return self;
}

- (void)start {
    self.isExecuting = YES;
    self.isFinished = NO;

    //    [NSThread sleepForTimeInterval:0.3f];

    NSString *website_string = [[NSUserDefaults standardUserDefaults] stringForKey:@"website_url"];
    NSString *string_url = [NSString stringWithFormat:@"%@/admin/products.json?published_status=published&collection_id=%@&page=%d&limit=1", website_string, self.collectionId, self.pageNumber];
    NSURL *url = [NSURL URLWithString:string_url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setValue:self.token forHTTPHeaderField:@"X-Shopify-Access-Token"];
    [request setURL:url];

    __weak typeof(self) wSelf = self;

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                             if (!error) {
                                 NSLog(@"collection id : %@", self.collectionId);
                                 NSDictionary *dicFromServer_products = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                 NSMutableArray *arrayForProducts = [[dicFromServer_products objectForKey:@"products"] mutableCopy];
                                 
                                 NSMutableArray *updatedProducts = [[NSMutableArray alloc] init];
                                 if (arrayForProducts.count) [updatedProducts addObjectsFromArray:arrayForProducts];
                                 if (self.downloadedProducts) [updatedProducts addObjectsFromArray:self.downloadedProducts];

                                 if (arrayForProducts.count == 1) {
                                     
                                     
                                     [self willChangeValueForKey:@"isFinished"];
                                     [self willChangeValueForKey:@"isExecuting"];
                                     
                                     self.isFinished = YES;
                                     self.isExecuting = NO;
                                     
                                     [self didChangeValueForKey:@"isExecuting"];
                                     [self didChangeValueForKey:@"isFinished"];
                                     
                                     ProductsDownlaodOperation *productsOperation = [[ProductsDownlaodOperation alloc]
                                          initWithCollectionId:wSelf.collectionId
                                                    pageNumber:(wSelf.pageNumber + 1)
                                                         token:wSelf.token
                                         downloadedCollections:arrayForProducts
                                               completionBlock:wSelf.block2];
                                     if ([NSOperationQueue currentQueue]) {
                                         [[NSOperationQueue currentQueue] addOperation:productsOperation];
                                     }

                                     //add a waiting queue
                                     [[NSOperationQueue currentQueue] addOperationWithBlock:^{
                                       [NSThread sleepForTimeInterval:0.3f];
                                     }];

                                 } else {
                                     [self endProductsDownlaodWithProducts:updatedProducts forCollectionId:self.collectionId error:nil];
                                 }
                             } else {
                             }

                           }];
}

- (void)endProductsDownlaodWithProducts:(NSArray *)products forCollectionId:(NSString *)collectionId error:(NSError *)error {
    
    if (self.block2) {
        self.block2(products, collectionId, error);
    }
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    self.isFinished = YES;
    self.isExecuting = NO;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isCancelled {
    BOOL isCancelled = [super isCancelled];

    if (isCancelled == YES) {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];

        self.isFinished = YES;
        self.isExecuting = NO;

        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
    }
    return isCancelled;
}

@end
