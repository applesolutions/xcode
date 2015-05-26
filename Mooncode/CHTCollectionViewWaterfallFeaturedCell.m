//
//  CHTCollectionViewWaterfallFeaturedCell.m
//  Mooncode
//
//  Created by amaury soviche on 19/05/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "CHTCollectionViewWaterfallFeaturedCell.h"

@implementation CHTCollectionViewWaterfallFeaturedCell

#pragma mark - Life Cycle
- (void)dealloc {
    [_displayLabel removeFromSuperview];
    _displayLabel = nil;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;

        _displayLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        _displayLabel.frame = CGRectMake(0, 0, self.frame.size.width - 40, 0.5 * self.frame.size.height);
        _displayLabel.adjustsFontSizeToFitWidth = YES;
        _displayLabel.minimumFontSize = 0;
        _displayLabel.textAlignment = UITextAlignmentCenter;
        _displayLabel.numberOfLines = 2;
        _displayLabel.textColor = [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorLabelCollections"] objectForKey:@"red"] floatValue] / 255
                                                  green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorLabelCollections"] objectForKey:@"green"] floatValue] / 255
                                                   blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorLabelCollections"] objectForKey:@"blue"] floatValue] / 255
                                                  alpha:1];
        _displayLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:25];
        _displayLabel.adjustsFontSizeToFitWidth = YES;
        _displayLabel.center = self.contentView.center;

        _viewWhite.translatesAutoresizingMaskIntoConstraints = NO;
        _viewWhite = [[UIView alloc] initWithFrame:self.contentView.frame];

        [self addSubview:_viewWhite];
        [self bringSubviewToFront:self.displayLabel];

        [self addSubview:_displayLabel];
        [self bringSubviewToFront:_displayLabel];

        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;

        self.backgroundColor = [UIColor whiteColor];

        // Scale the imageview to fit inside the contentView with the image centered:
        CGRect imageViewFrame = CGRectMake(0.f, 0.f, CGRectGetMaxX(self.contentView.bounds), CGRectGetMaxY(self.contentView.bounds));
        self.imageView.frame = imageViewFrame;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];

        self.imageViewSale = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.contentView.bounds) - 40, 10, 30, 30)];
        self.imageViewSale.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageViewSale];
        [self.imageViewSale bringSubviewToFront:self.imageViewSale];
    }
    return self;
}

@end
