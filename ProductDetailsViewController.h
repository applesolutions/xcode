//
//  ProductDetailsViewController.h
//  208
//
//  Created by amaury soviche on 25/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerViewOptions.h"

@interface ProductDetailsViewController : UIViewController < UIScrollViewDelegate, PickerViewOptions>

@property (strong, nonatomic) UIImage *image;
@property(strong, nonatomic) __block NSDictionary *dicProduct;
@property NSString *product_id;

@end
