//
//  CHTCollectionViewWaterfallFeaturedCell.m
//  Mooncode
//
//  Created by amaury soviche on 19/05/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "CHTCollectionViewWaterfallFeaturedCell.h"

@implementation CHTCollectionViewWaterfallFeaturedCell

#pragma mark - Accessors
- (UILabel *)displayLabel {
    if (!_displayLabel) {
        _displayLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        _displayLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _displayLabel.textColor = [UIColor whiteColor];
        _displayLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _displayLabel;
}

- (void)setDisplayString:(NSString *)displayString {
    if (![_displayString isEqualToString:displayString]) {
        _displayString = [displayString copy];
        self.displayLabel.text = _displayString;
    }
}

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
        _displayLabel.frame = CGRectMake(0, 0, self.frame.size.width - 40, 0.2 * self.frame.size.height);
        _displayLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        _displayLabel.adjustsFontSizeToFitWidth = YES;
        _displayLabel.minimumFontSize = 0;
        _displayLabel.textAlignment = UITextAlignmentCenter;
        _displayLabel.font = [UIFont fontWithName:@"ProximaNova-SemiBold" size:13];
        _displayLabel.adjustsFontSizeToFitWidth = YES;
        _displayLabel.numberOfLines = 2;
        _displayLabel.textColor = [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorLabelCollections"] objectForKey:@"red"] floatValue] / 255
                                                  green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorLabelCollections"] objectForKey:@"green"] floatValue] / 255
                                                   blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorLabelCollections"] objectForKey:@"blue"] floatValue] / 255
                                                  alpha:1];

        _viewWhite.translatesAutoresizingMaskIntoConstraints = NO;
        _viewWhite = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height - 0.2 * self.contentView.frame.size.height, self.contentView.frame.size.width, 0.2 * self.contentView.frame.size.height)];

        _displayLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
        _displayLabel.adjustsFontSizeToFitWidth = YES;

        _displayLabel.center = _viewWhite.center;

        [self.contentView addSubview:_viewWhite];
        [self.contentView bringSubviewToFront:self.displayLabel];

        [self.contentView addSubview:_displayLabel];
        [self.contentView bringSubviewToFront:_displayLabel];

        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;

        self.backgroundColor = [UIColor whiteColor];

        // Scale the imageview to fit inside the contentView with the image centered:
        CGRect imageViewFrame = CGRectMake(0.f, 0.f, CGRectGetMaxX(self.contentView.bounds), CGRectGetMaxY(self.contentView.bounds));
        self.imageView.frame = imageViewFrame;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.clipsToBounds = YES;
        //        [self.contentView addSubview:self.imageView];

        self.imageViewSale = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.contentView.bounds) - 40, 10, 30, 30)];
        self.imageViewSale.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageViewSale];
        [self.imageViewSale bringSubviewToFront:self.imageViewSale];
    }
    return self;
}

@end
