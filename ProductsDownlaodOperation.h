//
//  ProductsDownlaodOperation.h
//  Mooncode
//
//  Created by amaury soviche on 23/05/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(NSURLResponse *response, NSData *data, NSError *error, NSString *collectionId, int pageNumber);
typedef void (^CompletionBlock2)(NSArray *products, NSString *collectionId, NSError *error);

@interface ProductsDownlaodOperation : NSOperation

@property(readonly) BOOL isExecuting;
@property(readonly) BOOL isFinished;

@property (strong, nonatomic) NSString *collectionId;
@property int pageNumber;
@property (strong, nonatomic) NSString *token;
@property(nonatomic,copy) CompletionBlock block;
@property(nonatomic,copy) CompletionBlock2 block2;
@property (nonatomic, strong) NSArray *downloadedProducts;


-(id)initWithCollectionId:(NSString*)collectionId pageNumber:(int)pageNumber token:(NSString*)token completionBlock:(CompletionBlock)completionBlock;
-(id)initWithCollectionId:(NSString*)collectionId token:(NSString*)token completionBlock:(CompletionBlock2)completionBlock2;

-(id)initWithCollectionId:(NSString*)collectionId pageNumber:(int)pageNumber token:(NSString*)token downloadedCollections:(NSArray*)downloadedProducts completionBlock:(CompletionBlock2)completionBlock;


@end
