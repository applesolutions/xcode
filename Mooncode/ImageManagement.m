//
//  ImageManagement.m
//  208
//
//  Created by amaury soviche on 10/12/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "ImageManagement.h"


@implementation ImageManagement

+(void) saveImageWithData : (NSData*) imageData forName: (NSString *) imageName{
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",imageName]];
        
        [imageData writeToFile:imagePath atomically:NO];
//    });
}

+(void) deleteImageInMemoryWithName : (NSString*) imageName{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",imageName]];
        
        if (![[NSData data] writeToFile:imagePath atomically:NO])
            NSLog(@"Failed to cache image data to disk");
        else
            NSLog(@"the image has been deleted  : %@",imagePath);
    });
}

+(UIImage *) getImageFromMemoryWithName : (NSString *) nameImage{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",nameImage]];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}

@end
