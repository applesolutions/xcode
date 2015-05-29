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

#pragma mark - Init Methods

- (id)initWithCollectionId:(NSString *)collectionId token:(NSString *)token completionBlock:(ProductsCompletion)completionHandler {
    if (![super init]) return nil;

    _collectionId = collectionId;
    _pageNumber = 1;
    _token = token;
    _completionHandler = completionHandler;

    return self;
}

- (id)initWithCollectionId:(NSString *)collectionId pageNumber:(int)pageNumber token:(NSString *)token downloadedCollections:(NSArray *)downloadedProducts completionBlock:(ProductsCompletion)completionHandler {
    if (![super init]) return nil;

    _collectionId = collectionId;
    _pageNumber = pageNumber;
    _token = token;
    _completionHandler = completionHandler;
    _downloadedProducts = downloadedProducts;

    return self;
}

#pragma mark - Overridden Methods

- (void)start {
    if (self.isCancelled == YES) {
        NSError *canceledError = [NSError errorWithDomain:@"productsOperationCanceled" code:500 userInfo:nil];
        [self endProductsDownlaodWithProducts:self.downloadedProducts forCollectionId:self.collectionId error:canceledError];
        return;
    }

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

                             if (self.isCancelled == YES) {
                                 NSError *canceledError = [NSError errorWithDomain:@"productsOperationCanceled" code:500 userInfo:nil];
                                 [wSelf endProductsDownlaodWithProducts:wSelf.downloadedProducts forCollectionId:wSelf.collectionId error:canceledError];
                                 return;
                             }

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
                                               completionBlock:wSelf.completionHandler];
                                     if ([NSOperationQueue currentQueue]) {
                                         [[NSOperationQueue currentQueue] addOperation:productsOperation];
                                     }

                                     //add a waiting queue
                                     [[NSOperationQueue currentQueue] addOperationWithBlock:^{
                                       [NSThread sleepForTimeInterval:0.3f];
                                     }];

                                 } else {
                                     [wSelf endProductsDownlaodWithProducts:updatedProducts forCollectionId:self.collectionId error:nil];
                                 }
                             } else {
                                 [wSelf endProductsDownlaodWithProducts:wSelf.downloadedProducts forCollectionId:wSelf.collectionId error:error];
                             }

                           }];
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

#pragma mark - Helper

- (void)endProductsDownlaodWithProducts:(NSArray *)products forCollectionId:(NSString *)collectionId error:(NSError *)error {
    if (self.completionHandler) {
        self.completionHandler(products, collectionId, error);
    }

    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    self.isFinished = YES;
    self.isExecuting = NO;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
