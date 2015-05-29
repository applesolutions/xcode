//
//  CollectionsDownloaderOperation.m
//  Mooncode
//
//  Created by amaury soviche on 24/05/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "CollectionsDownloaderOperation.h"

@interface CollectionsDownloaderOperation ()

@property(assign) BOOL isExecuting;
@property(assign) BOOL isFinished;

@end

@implementation CollectionsDownloaderOperation

@synthesize isExecuting, isFinished;

#pragma mark - Init Methods

- (id)initWithToken:(NSString *)token completionBlock:(CollectionsCompletion)completionHandler {
    if (![super init]) return nil;
    _token = token;
    _completionHandler = completionHandler;
    return self;
}

#pragma mark - Overridden Methods

- (void)start {
    if (self.isCancelled == YES) {
        [self sendCancelCompletionBlock];
        return;
    }

    self.isExecuting = YES;
    self.isFinished = NO;

    __weak typeof(self) wSelf = self;
    __block NSMutableArray *downloadedCollections = [[NSMutableArray alloc] init];

    //SMART COLLECTIONS
    NSString *websiteString = [[NSUserDefaults standardUserDefaults] stringForKey:@"website_url"];
    NSString *stringUrlSmart = [NSString stringWithFormat:@"%@/admin/smart_collections.json?limit=250", websiteString];
    NSURL *urlSmart = [NSURL URLWithString:stringUrlSmart];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlSmart];
    [request setValue:self.token forHTTPHeaderField:@"X-Shopify-Access-Token"];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                             if (self.isCancelled == YES) {
                                 [wSelf sendCancelCompletionBlock];
                                 return;
                             }

                             if (!error) {
                                 NSMutableDictionary *smartCollections = [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] mutableCopy];
                                 [downloadedCollections addObject:smartCollections[@"smart_collections"]];

                                 //CUSTOM COLLECTIONS
                                 NSString *stringUrlCustom = [NSString stringWithFormat:@"%@/admin/custom_collections.json?limit=250", websiteString];
                                 NSURL *urlCustom = [NSURL URLWithString:stringUrlCustom];
                                 NSMutableURLRequest *requestCustom = [[NSMutableURLRequest alloc] initWithURL:urlCustom];
                                 [requestCustom setValue:wSelf.token forHTTPHeaderField:@"X-Shopify-Access-Token"];
                                 [NSURLConnection sendAsynchronousRequest:requestCustom
                                                                    queue:[[NSOperationQueue alloc] init]
                                                        completionHandler:^(NSURLResponse *responseCustom, NSData *dataCustom, NSError *errorCustom) {

                                                          if (self.isCancelled == YES) {
                                                              [wSelf sendCancelCompletionBlock];
                                                              return;
                                                          }

                                                          if (!errorCustom) {
                                                              NSMutableDictionary *dicFromServer_custom = [[NSJSONSerialization JSONObjectWithData:dataCustom options:kNilOptions error:&errorCustom] mutableCopy];
                                                              [downloadedCollections addObjectsFromArray:dicFromServer_custom[@"custom_collections"]];

                                                              [wSelf endedDownlaodWithCollections:downloadedCollections error:nil];

                                                          } else {
                                                              [wSelf endedDownlaodWithCollections:nil error:errorCustom];
                                                          }

                                                        }];

                             } else {
                                 [wSelf endedDownlaodWithCollections:nil error:error];
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

- (void)sendCancelCompletionBlock {
    NSError *canceledError = [NSError errorWithDomain:@"collectionsOperationCanceled" code:500 userInfo:nil];
    [self endedDownlaodWithCollections:nil error:canceledError];
}

- (void)endedDownlaodWithCollections:(NSArray *)collections error:(NSError *)error {
    if (self.completionHandler) {
        self.completionHandler(collections, error);
    }

    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    self.isFinished = YES;
    self.isExecuting = NO;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
