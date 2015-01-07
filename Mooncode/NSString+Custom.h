//
//  NSString+Custom.h
//  208
//
//  Created by amaury soviche on 10/12/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Custom)

- (CGFloat)getWidthWithFont:(UIFont*)font ;

- (NSString * )stringAmountWithThousandsSeparator;

@end
