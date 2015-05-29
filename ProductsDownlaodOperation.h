//
//  ProductsDownlaodOperation.h
//  Mooncode
//
//  Created by amaury soviche on 23/05/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ProductsCompletion)(NSArray *products, NSString *collectionId, NSError *error);

@interface ProductsDownlaodOperation : NSOperation

@property(readonly) BOOL isExecuting;
@property(readonly) BOOL isFinished;

@property (strong, nonatomic) NSString *collectionId;
@property int pageNumber;
@property (strong, nonatomic) NSString *token;
@property(nonatomic,copy) ProductsCompletion completionHandler;
@property (nonatomic, strong) NSArray *downloadedProducts;


-(id)initWithCollectionId:(NSString*)collectionId token:(NSString*)token completionBlock:(ProductsCompletion)completionHandler;
-(id)initWithCollectionId:(NSString*)collectionId pageNumber:(int)pageNumber token:(NSString*)token downloadedCollections:(NSArray*)downloadedProducts completionBlock:(ProductsCompletion)completionHandler;


@end
