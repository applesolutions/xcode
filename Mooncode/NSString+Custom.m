//
//  NSString+Custom.m
//  208
//
//  Created by amaury soviche on 10/12/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "NSString+Custom.h"


@implementation NSString (Custom)

- (CGFloat)getWidthWithFont:(UIFont*)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:(NSString*)self attributes:attributes] size].width;
}

- (NSString * )stringAmountWithThousandsSeparator{
    @try {
        NSNumber *number = [NSNumber numberWithFloat:[[NSString stringWithFormat:@"%@", self] floatValue]];
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
        [numberFormatter setGroupingSeparator:@"."];
        return [numberFormatter stringFromNumber: number];
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@", [exception description]);
    }
    @finally {
        
    }

}

+(void)test_LOG{
    NSLog(@"%@", (NSString*)self);
}

@end
