//
//  AcceptedPayementView.m
//  OneSnap
//
//  Created by amaury soviche on 04/09/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "AcceptedPayementView.h"


@implementation AcceptedPayementView

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = UIColorFromRGB(0xF3F3F3);
        self.alpha = 0.8;

        
    }
    return self;
}

@end
