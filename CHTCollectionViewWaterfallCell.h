//
//  UICollectionViewWaterfallCell.h
//  Demo
//
//  Created by Nelson on 12/11/27.
//  Copyright (c) 2012年 Nelson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHTCollectionViewWaterfallCell : UICollectionViewCell
@property (nonatomic, copy) NSString *displayString;
@property (nonatomic, strong) IBOutlet UILabel *displayLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) IBOutlet UIView *viewWhite;

@property (nonatomic, strong)  UIImageView *imageViewSale;

@end
