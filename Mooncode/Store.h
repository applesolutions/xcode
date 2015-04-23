//
//  Store.h
//  Mooncode
//
//  Created by amaury soviche on 23/04/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Store : NSObject

+(void) fetchSettingsFromServer:(void (^)(NSString*token, NSError*error))callback;


@end
