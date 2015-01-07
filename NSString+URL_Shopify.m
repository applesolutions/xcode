//
//  NSString+URL_Shopify.m
//  208
//
//  Created by amaury soviche on 10/12/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "NSString+URL_Shopify.h"
#import <UIKit/UIKit.h>

@implementation NSString (URL_Shopify)

-(NSString*)getShopifyUrlforSize : (NSString*)imageSize{
    
    NSLog(@"aaaaa");
    
    NSArray *myWords = [self componentsSeparatedByString:@"?"];
    NSString *stringBefore = [myWords objectAtIndex:0];
    
    NSArray *array2 = [stringBefore componentsSeparatedByString:@"."];
    
    int count = 0;
    
    NSString *shopifyUrl = @"";
    
    for (NSString *comp in array2) {
        if (count < [array2 count] - 1) {
            shopifyUrl = [shopifyUrl stringByAppendingString:comp] ;
            
            if (count < [array2 count] - 2) {
                shopifyUrl  = [shopifyUrl stringByAppendingString:@"."];
            }
        }
        count++;
    }
    
    @try {
        shopifyUrl = [[[[shopifyUrl stringByAppendingString:[NSString stringWithFormat:@"_%@.", imageSize]] stringByAppendingString:[array2 lastObject]] stringByAppendingString:@"?"] stringByAppendingString:[myWords objectAtIndex:1]];
        NSLog(@"url to download : %@", shopifyUrl);
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@", [exception description]);
    }
    @finally {
        
    }
    
    return shopifyUrl;
}


@end
