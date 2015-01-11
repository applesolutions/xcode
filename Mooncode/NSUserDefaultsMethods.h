//
//  NSUserDefaultsMethods.h
//  Mooncode
//
//  Created by amaury soviche on 22/12/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface NSUserDefaultsMethods : NSObject




+(void) saveStoreDetailsWithPfObject:(PFObject*) applicationToStore;


//SAVE
+(BOOL)saveObjectInMemory:(id)objectToStore toFolder:(NSString*)folderName;

//GET
+(id)getObjectFromMemoryInFolder:(NSString*)folderName;

//DELETE
+(void)removeFilesInFolderWithName:(NSString*)folderName;

@end
