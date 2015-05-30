//
//  CollectionsHelper.h
//  Mooncode
//
//  Created by amaury soviche on 29/05/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionsHelper : NSObject

+ (BOOL)isMissingCollectionsInMemoryToDisplayWithProducts:(NSDictionary *)dicCollections collections:(NSDictionary *)dicProductsCorrespondingToCollections;
+ (NSMutableArray *)sortCollectionsInArray:(NSArray *)collectionsToBeSorted;
+ (NSArray *)collectionsToKeepFromServerWithInitialArray:(NSArray *)initialCollections;
+ (NSDictionary *)fromArrayToDictionary:(NSArray *)collections;

@end
