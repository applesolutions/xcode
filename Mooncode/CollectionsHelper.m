//
//  CollectionsHelper.m
//  Mooncode
//
//  Created by amaury soviche on 29/05/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "CollectionsHelper.h"
#import "NSUserDefaultsMethods.h"

@implementation CollectionsHelper

+ (BOOL)isMissingCollectionsInMemoryToDisplayWithProducts:(NSDictionary *)dicCollections collections:(NSDictionary *)dicProductsCorrespondingToCollections {
    NSArray *displayedCollectionsFromServer = [NSUserDefaultsMethods getObjectFromMemoryInFolder:@"displayedCollections"];

    //check we have in memeory all the collections to display (from server) + display the ones we have
    BOOL missingCollections = NO;
    for (NSDictionary *collection in displayedCollectionsFromServer) {
        if (!dicCollections[[collection[@"shopify_collection_id"] stringValue]] ||                         // not in our collections
            !dicProductsCorrespondingToCollections[[collection[@"shopify_collection_id"] stringValue]]) {  // not in our products
            missingCollections = YES;
            break;
        }
    }
    return missingCollections;
}

+ (NSMutableArray *)sortCollectionsInArray:(NSArray *)collectionsToBeSorted {
    return [[collectionsToBeSorted sortedArrayUsingComparator:^NSComparisonResult(id collection1, id collection2) {
      if ([NSNull null] != collection1[@"display_position"] && [NSNull null] != collection2[@"display_position"]) {
          return [collection1[@"display_position"] compare:collection2[@"display_position"]];
      } else {
          return (NSComparisonResult)NSOrderedSame;
      }
    }] mutableCopy];
}

+ (NSArray *)collectionsToKeepFromServerWithInitialArray:(NSArray *)initialCollections {
    NSArray *arrayCustomCollectionsIds = [[NSUserDefaults standardUserDefaults] objectForKey:@"arrayCustomCollectionsIds"];

    NSMutableArray *collectionsWanted = [[NSMutableArray alloc] init];
    for (NSDictionary *dicCollection in initialCollections) {
        if ([arrayCustomCollectionsIds containsObject:[dicCollection[@"id"] stringValue]]) {
            [collectionsWanted addObject:dicCollection];
            continue;
        }
    }
    return [collectionsWanted copy];
}

+ (NSDictionary *)fromArrayToDictionary:(NSArray *)collections {
    NSMutableDictionary *transformedCollections = [[NSMutableDictionary alloc] init];

    for (NSDictionary *dicCollection in collections) {
        transformedCollections[[dicCollection[@"id"] stringValue]] = dicCollection;
    }
    return [transformedCollections copy];
}

@end
