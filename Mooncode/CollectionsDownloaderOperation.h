//
//  CollectionsDownloaderOperation.h
//  Mooncode
//
//  Created by amaury soviche on 24/05/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CollectionsCompletion)(NSArray *collections, NSError *error);

@interface CollectionsDownloaderOperation : NSOperation

@property(readonly) BOOL isExecuting;
@property(readonly) BOOL isFinished;

@property(strong, nonatomic) NSString *token;
@property(nonatomic, copy) CollectionsCompletion completionHandler;
@property(nonatomic, strong) NSArray *downloadedCollections;

- (id)initWithToken:(NSString *)token completionBlock:(CollectionsCompletion)completionHandler;

@end
