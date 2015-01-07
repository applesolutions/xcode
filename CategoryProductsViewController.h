//
//  CategoryProductsViewController.h
//  208
//
//  Created by amaury soviche on 28/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"

@interface CategoryProductsViewController : UIViewController <CHTCollectionViewDelegateWaterfallLayout>

@property NSString *categoryName; // this is the id...

@property NSString *collectionName;

@property (strong,nonatomic) NSMutableArray *arrayProducts;

@end
