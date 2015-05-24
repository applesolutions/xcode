//
//  ProductsDownlaodOperation.h
//  Mooncode
//
//  Created by amaury soviche on 23/05/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(NSURLResponse *response, NSData *data, NSError *error, NSString *collectionId, int pageNumber);

@interface ProductsDownlaodOperation : NSOperation

@property (strong, nonatomic) NSString *collectionId;
@property int pageNumber;
@property (strong, nonatomic) NSString *token;
@property(nonatomic,copy) CompletionBlock block;

-(id)initWithCollectionId:(NSString*)collectionId pageNumber:(int)pageNumber token:(NSString*)token completionBlock:(CompletionBlock)completionBlock;



@end
