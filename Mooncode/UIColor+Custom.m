//
//  UIColor+Custom.m
//  Mooncode
//
//  Created by amaury soviche on 01/06/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "UIColor+Custom.h"

@implementation UIColor (Custom)

+ (UIColor *)colorFromMemoryNamed:(NSString *)colorName {
    return [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:colorName] objectForKey:@"red"] floatValue] / 255
                           green:[[[[NSUserDefaults standardUserDefaults] objectForKey:colorName] objectForKey:@"green"] floatValue] / 255
                            blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:colorName] objectForKey:@"blue"] floatValue] / 255
                           alpha:[[[[NSUserDefaults standardUserDefaults] objectForKey:colorName] objectForKey:@"alpha"] floatValue]];
}

@end
