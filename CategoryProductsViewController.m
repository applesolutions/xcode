//
//  CategoryProductsViewController.m
//  208
//
//  Created by amaury soviche on 28/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "CategoryProductsViewController.h"

#import "CHTCollectionViewWaterfallCell.h"
#import "CHTCollectionViewWaterfallHeader.h"
#import "CHTCollectionViewWaterfallFooter.h"

#import "ProductDetailsViewController.h"
#import "CartViewController.h"

#import "ScrollViewController.h"

#import "ImageManagement.h"

@interface CategoryProductsViewController ()

#define CELL_IDENTIFIER @"WaterfallCell"
#define HEADER_IDENTIFIER @"WaterfallHeader"
#define FOOTER_IDENTIFIER @"WaterfallFooter"

@property (nonatomic, strong) ScrollViewController *stlmMainViewController;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonCart;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;

@property (strong, nonatomic) UIActivityIndicatorView *activity;

@property (nonatomic, strong) __block NSMutableArray *cellSizes;

@property (strong, nonatomic) IBOutlet UIImageView *imageWaiting;

@property (strong, nonatomic) IBOutlet UIView *ViewNavBar;

@property (weak, nonatomic) IBOutlet UIView *ViewNoProduct;
@end

@implementation CategoryProductsViewController{
    
    NSMutableArray *arrayIds_memory;
    NSMutableArray *arrayProductsForCategory;
    
    NSMutableArray *arrayIndexesActiclesOnSales;
}

#pragma mark - Life Cycle

-(void) viewWillAppear:(BOOL)animated{
    NSData *dataFromMemory = [[NSUserDefaults standardUserDefaults]objectForKey:@"arrayProductsInCart"];
    
    if([[NSKeyedUnarchiver unarchiveObjectWithData:dataFromMemory] count] == 0 ){
        self.buttonCart.image = [[UIImage imageNamed:@"nav-icon-cart"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }else{
        self.buttonCart.image = [[UIImage imageNamed:@"nav-icon-cart-full"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
    }
    
    self.ViewNavBar.backgroundColor =
    [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"red"] floatValue] / 255
                    green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"green"] floatValue] / 255
                     blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"blue"] floatValue] / 255
                    alpha:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"alpha"] floatValue]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.arrayProducts.count == 0) { //no product to display
        self.collectionView.hidden = YES;
        self.imageWaiting.hidden = YES;
        self.ViewNoProduct.hidden = NO;
        return;
    }
    
    self.ViewNoProduct.hidden = YES;
    
    CGRect frame = self.collectionView.frame;
    frame.origin.y = 64;
    frame.size.height = self.view.frame.size.height - 64;
    self.collectionView.frame = frame;
    
    self.activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.view bringSubviewToFront:self.activity];
    self.activity.color = [UIColor blackColor];
    self.activity.center = self.view.center;
    [self.view addSubview:self.activity];
    [self.activity startAnimating];
    
    self.navBar.topItem.title = self.collectionName;
    
    arrayProductsForCategory = self.arrayProducts;
    
    if ([self.arrayProducts count] < 50) {

        _cellSizes = [NSMutableArray new];
        [self defineCellsHeights];
        
        self.activity.hidden = YES;
        [self.activity stopAnimating];
        
        self.imageWaiting.hidden = YES;
        [self.view addSubview:self.collectionView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self.arrayProducts count] >= 50) {
        
        _cellSizes = [NSMutableArray new];

        [self defineCellsHeights];
        
        self.activity.hidden = YES;
        [self.activity stopAnimating];
        
        self.imageWaiting.hidden = YES;
        
        self.collectionView.hidden = NO;
        [self.view addSubview:self.collectionView];
    }
}

#pragma mark IBActions

- (IBAction)goToCart:(id)sender {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard_autolayout" bundle:nil];
    CartViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"CartViewController"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc1 animated:YES completion:nil];
    });
}

- (IBAction)goBack:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Define cell sizes

-(void) defineCellsHeights{
    
    arrayIndexesActiclesOnSales = [NSMutableArray new];
    
    [arrayProductsForCategory enumerateObjectsUsingBlock:^(id dicProduct, NSUInteger idx, BOOL *stop) {
        
        
        [[dicProduct objectForKey:@"variants"] enumerateObjectsUsingBlock:^(id dicVariant, NSUInteger idx_variant, BOOL *stop) {
            
            if ( ! [[dicVariant objectForKey:@"compare_at_price"] isKindOfClass:[NSNull class]]) {
                
                [arrayIndexesActiclesOnSales addObject:[NSNumber numberWithUnsignedInteger:idx]];
                *stop=YES;
            }
        }];
//        NSLog(@"description array indexes : %@", [arrayIndexesActiclesOnSales description] );
        
        NSString *productId = [[dicProduct objectForKey:@"id"] stringValue];
        
        CGSize imageSize = [ImageManagement getImageFromMemoryWithName:productId].size;
        float image_ratio = 157/imageSize.width;
        float image_newHeight = image_ratio * imageSize.height;
        
        CGSize size;
        if ([arrayIds_memory indexOfObject:productId] == 0) {
            size = CGSizeMake(157, (int)image_newHeight);
        }else if ([arrayIds_memory indexOfObject:productId] == 1){
            size = CGSizeMake(157, (int)image_newHeight * 0.85);
        }else if ([arrayIds_memory indexOfObject:productId] == 2) {
            size = CGSizeMake(157, (int)image_newHeight * 0.85);
        }else if ([arrayIds_memory indexOfObject:productId] == 3){
            size = CGSizeMake(157, (int)image_newHeight);
        }
        else{
            int lowerBound = 85;
            int upperBound = 100;
            float randRatio = (int)(lowerBound + arc4random() % (upperBound - lowerBound))/100.0;
            size = CGSizeMake(157, (int)(image_newHeight * randRatio));
        }
        
//        NSLog(@"size : %@", NSStringFromCGSize(size));
        
        [self.cellSizes addObject:[NSValue valueWithCGSize:size]];
    }];
    
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [arrayProductsForCategory count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CHTCollectionViewWaterfallCell *cell = (CHTCollectionViewWaterfallCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    NSString *product_id = [[arrayProductsForCategory objectAtIndex:indexPath.row] objectForKey:@"id"];

    cell.viewWhite.hidden = YES;
    cell.imageView.image = [ImageManagement getImageFromMemoryWithName:product_id];
    
    if ([arrayIndexesActiclesOnSales containsObject:[NSNumber numberWithInteger:indexPath.row]]) {
        
        cell.imageViewSale.image = [UIImage imageNamed:@"icon-sale"];
    }else{
        
        cell.imageViewSale.image = nil;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard_autolayout" bundle:nil];
    ProductDetailsViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"ProductDetailsViewController"];
    vc1.dicProduct = [arrayProductsForCategory objectAtIndex:indexPath.row];
    vc1.product_id =[[arrayProductsForCategory objectAtIndex:indexPath.row] objectForKey:@"id"];
    vc1.image = [ImageManagement getImageFromMemoryWithName:[[arrayProductsForCategory objectAtIndex:indexPath.row] objectForKey:@"id"]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:vc1 animated:YES];
    });
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    
    if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:HEADER_IDENTIFIER
                                                                 forIndexPath:indexPath];
    } else if ([kind isEqualToString:CHTCollectionElementKindSectionFooter]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:FOOTER_IDENTIFIER
                                                                 forIndexPath:indexPath];
    }
    
    return reusableView;
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellSizes[indexPath.item] CGSizeValue];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        layout.headerHeight = 0;
        layout.footerHeight = 0;
        layout.minimumColumnSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        if ([[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
            layout.columnCount = 3;
        }else{
            layout.columnCount = 2;
        }
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor =  [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"] objectForKey:@"red"] floatValue] / 255
                                                           green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"] objectForKey:@"green"] floatValue] / 255
                                                            blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"] objectForKey:@"blue"] floatValue] / 255
                                                           alpha:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"] objectForKey:@"alpha"] floatValue]];
        [_collectionView registerClass:[CHTCollectionViewWaterfallCell class]
            forCellWithReuseIdentifier:CELL_IDENTIFIER];
        [_collectionView registerClass:[CHTCollectionViewWaterfallHeader class]
            forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader
                   withReuseIdentifier:HEADER_IDENTIFIER];
        [_collectionView registerClass:[CHTCollectionViewWaterfallFooter class]
            forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter
                   withReuseIdentifier:FOOTER_IDENTIFIER];
    }
    return _collectionView;
}

@end
