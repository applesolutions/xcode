//
//  NSUserDefaultsMethods.m
//  Mooncode
//
//  Created by amaury soviche on 22/12/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "NSUserDefaultsMethods.h"


@implementation NSUserDefaultsMethods


+(void) saveStoreDetailsWithPfObject:(PFObject*) applicationToStore{
    
    [[NSUserDefaults standardUserDefaults] setObject:[applicationToStore objectForKey:@"website_url"] forKey:@"website_url"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[applicationToStore objectForKey:@"shopify_token"] forKey:@"shopify_token"];//
    [[NSUserDefaults standardUserDefaults] setObject:[applicationToStore objectForKey:@"shopify_name"] forKey:@"shopify_name"];//
    
    [[NSUserDefaults standardUserDefaults] setObject:[applicationToStore objectForKey:@"website_cart_url"] forKey:@"website_cart_url"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[applicationToStore objectForKey:@"twitterName"] forKey:@"twitterName"];
    [[NSUserDefaults standardUserDefaults] setObject:[applicationToStore objectForKey:@"supportEmail"] forKey:@"supportUrl"];
    [[NSUserDefaults standardUserDefaults] setObject:[applicationToStore objectForKey:@"CollectionType"] forKey:@"collectionType"];
    [[NSUserDefaults standardUserDefaults] setBool:[[applicationToStore objectForKey:@"areCollectionsDisplayed"] boolValue] forKey:@"areCollectionsDisplayed"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[applicationToStore objectForKey:@"currency"]  forKey:@"currency"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      [[applicationToStore objectForKey:@"navBarColors"] objectAtIndex:0], @"red",
                                                      [[applicationToStore objectForKey:@"navBarColors"] objectAtIndex:1] , @"green",
                                                      [[applicationToStore objectForKey:@"navBarColors"] objectAtIndex:2] , @"blue",  nil]
                                              forKey:@"colorNavBar"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      [[applicationToStore objectForKey:@"settingsPageColors"] objectAtIndex:0], @"red",
                                                      [[applicationToStore objectForKey:@"settingsPageColors"] objectAtIndex:1] , @"green",
                                                      [[applicationToStore objectForKey:@"settingsPageColors"] objectAtIndex:2] , @"blue",  nil]
                                              forKey:@"colorSettingsView"];

    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"app in userdef : %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"]);
}

+(void) removeFilesInFolderWithName:(NSString*)folderName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path =[documentsDirectory stringByAppendingPathComponent:folderName];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

+(id)getObjectFromMemoryInFolder:(NSString*)folderName{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:folderName];
    
    NSData *dataObject = [NSData dataWithContentsOfFile:imagePath];
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:dataObject];
}

+(BOOL)saveObjectInMemory:(id)objectToStore toFolder:(NSString*)folderName{
    //transform "application" to a savable file
    NSData *dataToStore = [NSKeyedArchiver archivedDataWithRootObject:objectToStore];
    //save it
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:folderName];
    
    if([dataToStore writeToFile:imagePath atomically:NO]){
        NSLog(@"datas well saved ! ");
        return YES;
    }else{
        NSLog(@"error saving file  ");
        return NO;
    }
}

@end