//
//  CHTCollectionViewWaterfallFeaturedCell.h
//  Mooncode
//
//  Created by amaury soviche on 19/05/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHTCollectionViewWaterfallFeaturedCell : UICollectionViewCell

@property (nonatomic, copy) NSString *displayString;
@property (nonatomic, strong) IBOutlet UILabel *displayLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIView *viewWhite;
@property (nonatomic, strong)  UIImageView *imageViewSale;

@property BOOL featuredCollection;

@end