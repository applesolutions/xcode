//
//  MOONAnalytics.h
//  Mooncode
//
//  Created by amaury soviche on 03/06/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOONAnalytics : NSObject

+ (instancetype)sharedManager;

-(void)sendAnalyticsForVisitedCollectionWithId:(NSString*)collectionId;

@end
