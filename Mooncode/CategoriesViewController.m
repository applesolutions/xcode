//
//  CategoriesViewController.m
//  208
//
//  Created by amaury soviche on 30/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "CategoriesViewController.h"

#import "CHTCollectionViewWaterfallCell.h"
#import "CHTCollectionViewWaterfallFeaturedCell.h"
#import "CHTCollectionViewWaterfallHeader.h"
#import "CHTCollectionViewWaterfallFooter.h"

#import "ProductDetailsViewController.h"
#import "CartViewController.h"
#import "ScrollViewController.h"
#import "CategoryProductsViewController.h"

#import "ImageManagement.h"
#import "NSString+URL_Shopify.h"
#import "ShopifyImages.h"

#import "NSUserDefaultsMethods.h"
#import "FCFileManager.h"
#import "AppDelegate.h"

#import "Store.h"
#import "ProtocolCell.h"

@interface CategoriesViewController ()

//IBOUTLETS
@property(strong, nonatomic) IBOutlet UIBarButtonItem *navBarButtonLeft;
@property(strong, nonatomic) IBOutlet UIBarButtonItem *buttonCart;

@property(strong, nonatomic) IBOutlet UIView *viewForLabel;
@property(strong, nonatomic) IBOutlet UIView *ViewNavBar;

@property(strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property(strong, nonatomic) IBOutlet UILabel *labelLoading;
@property(strong, nonatomic) IBOutlet UIActivityIndicatorView *activityLoading;
@property(strong, nonatomic) IBOutlet UIImageView *imageBackgroundForLoading;
@property(strong, nonatomic) IBOutlet UIButton *buttonReload;

//GLOBAL PROPERTIES
@property(strong, nonatomic) UICollectionView *collectionView;
@property(nonatomic, strong) ScrollViewController *stlmMainViewController;
@property(strong, nonatomic) UIRefreshControl *refreshControl;

@property(nonatomic) __block BOOL loading;
@property(nonatomic, copy) void (^fetchSettingsHandler)(NSString *token, NSArray *displayedCollections, NSArray *featuredCollections, NSError *error);

@property(nonatomic, strong) __block NSArray *displayedCollectionsForCV;  //arrays that have to be displayed ( collections + products downloaded )
@property(nonatomic, strong) __block NSArray *featuredCollectionsForCV;

@end

#define CELL_IDENTIFIER @"WaterfallCell"
#define CELL_FEATURED_IDENTIFIER @"CHTCollectionViewWaterfallFeaturedCell"

@implementation CategoriesViewController {
    __block NSString *token;

    __block NSMutableArray *arrayProducts;
    __block NSMutableArray *array_Updated_Products;
    __block NSMutableArray *arrayIndexesActiclesOnSales;

    __block NSMutableDictionary *dicProductsCorrespondingToCollections;
    __block NSMutableDictionary *dicCollections;

    __block NSMutableDictionary *dic_Updated_ProductsCorrespondingToCollections;
    __block NSMutableDictionary *dic_Updated_Collections;

    __block int count_collectionsToDownload;
    __block int count_imagesToBeDownloaded;
}

#pragma mark ViewLifeCycle

- (void)viewWillDisappear:(BOOL)animated {
    self.stlmMainViewController = (ScrollViewController *)self.parentViewController.parentViewController;
    [self.stlmMainViewController disableScrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    self.stlmMainViewController = (ScrollViewController *)self.parentViewController.parentViewController;
    [self.stlmMainViewController enableScrollView];

    NSData *dataFromMemory = [[NSUserDefaults standardUserDefaults] dataForKey:@"arrayProductsInCart"];

    if ([[NSKeyedUnarchiver unarchiveObjectWithData:dataFromMemory] count] == 0) {
        self.buttonCart.image = [[UIImage imageNamed:@"nav-icon-cart"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        self.buttonCart.image = [[UIImage imageNamed:@"nav-icon-cart-full"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }

    [self.collectionView reloadData];

    [self updateColors];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isInstagramIntegrated"] == YES) {
        self.navBarButtonLeft.image = [UIImage imageNamed:@"icon-instagram"];
    }

    self.viewForLabel.layer.cornerRadius = 5;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePhoneSettings)
                                                 name:@"updatePhoneSettings"
                                               object:nil];
}

- (void)updateColors {
    dispatch_async(dispatch_get_main_queue(), ^{

      self.ViewNavBar.backgroundColor =
          [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"red"] floatValue] / 255
                          green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"green"] floatValue] / 255
                           blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"blue"] floatValue] / 255
                          alpha:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"alpha"] floatValue]];
      [self.navBar setBarTintColor:self.ViewNavBar.backgroundColor];

      [AppDelegate setAppearance];

      [self.collectionView reloadData];
    });
}

- (void)updatePhoneSettings {
    [self updateColors];
}

- (void)updateCollectionsThatCanBeDisplayed {
    NSArray *displayedCollectionsFromServer = [NSUserDefaultsMethods getObjectFromMemoryInFolder:@"displayedCollections"];
    NSArray *featuredCollectionsFromServer = [NSUserDefaultsMethods getObjectFromMemoryInFolder:@"featuredCollections"];

    if (displayedCollectionsFromServer.count == 0) {
        [self noCollectionAvailable];
        return;
    }

    //check we have in memeory all the collections to display (from server) + display the ones we have

    NSMutableArray *updatedDisplayedCollectionsForCV = [[NSMutableArray alloc] init];
    for (NSDictionary *collection in displayedCollectionsFromServer) {
        if ([dicCollections objectForKey:[collection[@"shopify_collection_id"] stringValue]] &&                         // not in our collections
            [dicProductsCorrespondingToCollections objectForKey:[collection[@"shopify_collection_id"] stringValue]]) {  // not in our products
            [updatedDisplayedCollectionsForCV addObject:collection];
        }
    }

    //display all the featured collections we have in memeory
    NSMutableArray *updatedFeaturedCollectionsForCV = [[NSMutableArray alloc] init];
    for (NSDictionary *collection in featuredCollectionsFromServer) {
        if ([dicCollections objectForKey:[collection[@"shopify_collection_id"] stringValue]] &&                         // not in our collections
            [dicProductsCorrespondingToCollections objectForKey:[collection[@"shopify_collection_id"] stringValue]]) {  // not in our products
            [updatedFeaturedCollectionsForCV addObject:collection];
        }
    }

    self.displayedCollectionsForCV = updatedDisplayedCollectionsForCV;
    self.featuredCollectionsForCV = updatedFeaturedCollectionsForCV;

    dispatch_async(dispatch_get_main_queue(), ^{
      [self.collectionView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) wSelf = self;
    self.fetchSettingsHandler = ^void(NSString *updatedToken, NSArray *displayedCollectionsaaa, NSArray *featuredCollectionsaaa, NSError *error) {

      if (!error) {
          token = updatedToken;

          //update collections diplayed / featured
          NSArray *displayedCollectionsFromServer = [NSUserDefaultsMethods getObjectFromMemoryInFolder:@"displayedCollections"];
          NSArray *featuredCollectionsFromServer = [NSUserDefaultsMethods getObjectFromMemoryInFolder:@"featuredCollections"];

          if (displayedCollectionsFromServer.count == 0) {
              [wSelf noCollectionAvailable];
              return;
          }

          NSMutableArray *arrayCustomCollectionsIds = [[NSMutableArray alloc] init];
          for (NSDictionary *collection in displayedCollectionsFromServer) {
              [arrayCustomCollectionsIds addObject:[collection[@"shopify_collection_id"] stringValue]];
          }
          [[NSUserDefaults standardUserDefaults] setObject:arrayCustomCollectionsIds forKey:@"arrayCustomCollectionsIds"];
          [[NSUserDefaults standardUserDefaults] synchronize];

          //check we have in memeory all the collections to display (from server) + display the ones we have
          BOOL fetchCollectionsFromShopify = NO;
          NSMutableArray *updatedDisplayedCollectionsForCV = [[NSMutableArray alloc] init];
          for (NSDictionary *collection in displayedCollectionsFromServer) {
              if (![dicCollections objectForKey:[collection[@"shopify_collection_id"] stringValue]] ||                         // not in our collections
                  ![dicProductsCorrespondingToCollections objectForKey:[collection[@"shopify_collection_id"] stringValue]]) {  // not in our products
                  fetchCollectionsFromShopify = YES;
              } else {
                  [updatedDisplayedCollectionsForCV addObject:collection];
              }
          }

          //display all the featured collections we have in memeory
          NSMutableArray *updatedFeaturedCollectionsForCV = [[NSMutableArray alloc] init];
          for (NSDictionary *collection in featuredCollectionsFromServer) {
              if ([dicCollections objectForKey:[collection[@"shopify_collection_id"] stringValue]] &&                         // not in our collections
                  [dicProductsCorrespondingToCollections objectForKey:[collection[@"shopify_collection_id"] stringValue]]) {  // not in our products
                  [updatedFeaturedCollectionsForCV addObject:collection];
              }
          }

          wSelf.displayedCollectionsForCV = updatedDisplayedCollectionsForCV;
          wSelf.featuredCollectionsForCV = updatedFeaturedCollectionsForCV;

          dispatch_async(dispatch_get_main_queue(), ^{
            [wSelf.collectionView reloadData];
          });

          if (fetchCollectionsFromShopify == YES) [wSelf makeRequestForPage:1];

      } else {
          NSLog(@"error settings fetched: %@", error);
          if ([dicCollections count] == 0) {
              wSelf.activityLoading.hidden = YES;
              wSelf.labelLoading.text = @"No Internet connection detected.";
              wSelf.buttonReload.hidden = NO;
              wSelf.loading = NO;
          }
      }
    };

    [[self navigationController] setNavigationBarHidden:YES animated:YES];  //do not remove

    count_imagesToBeDownloaded = 0;

    CGRect frame = self.collectionView.frame;
    frame.origin.y = 64;
    frame.size.height = self.view.frame.size.height - 64;
    self.collectionView.frame = frame;
    [self.view addSubview:self.collectionView];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.collectionView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];

    array_Updated_Products = [[NSMutableArray alloc] init];
    arrayIndexesActiclesOnSales = [[NSMutableArray alloc] init];
    dic_Updated_Collections = [[NSMutableDictionary alloc] init];
    dic_Updated_ProductsCorrespondingToCollections = [[NSMutableDictionary alloc] init];

    dispatch_sync(dispatch_get_global_queue(0, 0), ^{

      if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == NO) {
          arrayProducts = [[NSUserDefaultsMethods getObjectFromMemoryInFolder:@"arrayProducts"] mutableCopy];

          if (arrayProducts != nil) {
              [self checkForProductsInSales];
              dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                [self hideLoading];
              });
          } else {
              arrayProducts = [NSMutableArray new];
              [self showLoading];
          }

      } else {
          dicCollections = [NSUserDefaultsMethods getObjectFromMemoryInFolder:@"datasForDicCollections"];
          dicProductsCorrespondingToCollections = [NSUserDefaultsMethods getObjectFromMemoryInFolder:@"datasForProductsAndCollections"];

          if (dicCollections != nil && dicProductsCorrespondingToCollections != nil) {
              dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                [self hideLoading];
              });

          } else {
              [self showLoading];
          }
      }

      [Store fetchSettingsFromServer:self.fetchSettingsHandler];
    });

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      //DO NOT BACK UP THE DATAS INTO ICLOUD
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
      NSString *documentsDirectory = [paths objectAtIndex:0];
      NSURL *pathURL = [NSURL fileURLWithPath:documentsDirectory];
      [self addSkipBackupAttributeToItemAtURL:pathURL];

      NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
      NSString *folder = [path objectAtIndex:0];
      NSURL *pathURLUserDef = [NSURL fileURLWithPath:folder];
      [self addSkipBackupAttributeToItemAtURL:pathURLUserDef];
    });
}

- (void)refreshTable {
    [self.refreshControl endRefreshing];

    if (self.loading == NO) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == YES) {
            [dic_Updated_Collections removeAllObjects];
            [dic_Updated_ProductsCorrespondingToCollections removeAllObjects];

            dic_Updated_Collections = [NSMutableDictionary new];
            dic_Updated_ProductsCorrespondingToCollections = [NSMutableDictionary new];

            count_collectionsToDownload = 0;

        } else {
            [array_Updated_Products removeAllObjects];
            array_Updated_Products = [NSMutableArray new];
        }

        [Store fetchSettingsFromServer:self.fetchSettingsHandler];
    }
}

#pragma mark request for products only

- (void)makeRequestForPage_productsOnly:(int)pageNumber {
    self.loading = YES;

    NSString *website_string = [[NSUserDefaults standardUserDefaults] stringForKey:@"website_url"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/admin/products.json?published_status=published&page=%d&limit=250", website_string, pageNumber]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setValue:token forHTTPHeaderField:@"X-Shopify-Access-Token"];
    [request setURL:url];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                             if (!error) {
                                 NSDictionary *dicFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                 [array_Updated_Products addObjectsFromArray:[dicFromServer objectForKey:@"products"]];
                                 //            NSLog(@"products from server : %@ ", [dicFromServer description]);

                                 int numberProductAtActualPage = (int)[[dicFromServer objectForKey:@"products"] count];
                                 if (numberProductAtActualPage == 250) {
                                     [self makeRequestForPage_productsOnly:(pageNumber + 1)];
                                 } else {  //all the products have been downloaded !

                                     //sort products by date of creation
                                     NSMutableArray *arrayProductsForSingleCollection = [array_Updated_Products mutableCopy];
                                     NSArray *sortedArrayProducts = [arrayProductsForSingleCollection sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                       return [obj2[@"id"] compare:obj1[@"id"]];
                                     }];
                                     array_Updated_Products = [sortedArrayProducts mutableCopy];

                                     //Save the products in memory
                                     [NSUserDefaultsMethods saveObjectInMemory:array_Updated_Products toFolder:@"arrayProducts"];

                                     //Convert to arrayProducts
                                     arrayProducts = [array_Updated_Products mutableCopy];

                                     [self checkForProductsInSales];

                                     //GET ALL IMAGES TO DOWNLOAD
                                     NSData *dicUpdateIPhone = [[NSUserDefaults standardUserDefaults] dataForKey:@"dateLastUpdateIPhone"];
                                     NSString *stringDateLastUpdateIPhone = [[NSKeyedUnarchiver unarchiveObjectWithData:dicUpdateIPhone] objectForKey:@"dateLastUpdateIPhone"];

                                     //get all unique images ! avoid to download each image several times !
                                     __block NSMutableArray *arrayIdsToBeDownloaded = [[NSMutableArray alloc] init];
                                     __block NSMutableArray *arrayUrlsToBeDownloaded = [[NSMutableArray alloc] init];

                                     for (NSDictionary *dicProduct in arrayProducts) {
                                         //                            //NSLog(@"dic product : %@", [dicProduct description]);

                                         NSString *stringDateProductUpdate = [dicProduct objectForKey:@"updated_at"];

                                         //                                //NSLog(@"date in iphone : %@", stringDateLastUpdateIPhone);
                                         //                                //NSLog(@"date update product : %@", stringDateProductUpdate);
                                         //                                //NSLog(@"title product to update : %@", [dicProduct objectForKey:@"title"]);

                                         if ([self hasBeenUpdatedWithStringDateReference:stringDateLastUpdateIPhone andStringDate:stringDateProductUpdate] || (                                                                                           // update !
                                                                                                                                                                  [ImageManagement getImageFromMemoryWithName:[dicProduct objectForKey:@"id"]] == nil &&  //first time !
                                                                                                                                                                  [dicProduct objectForKey:@"id"] != nil && [dicProduct objectForKey:@"image"] != nil)) {
                                             if ([arrayIdsToBeDownloaded containsObject:[dicProduct objectForKey:@"id"]]) {  //objectId already to download !
                                                 //NSLog(@"image already downloaded !");
                                                 continue;
                                             }

                                             if ([dicProduct objectForKey:@"image"]) {
                                                 //NSLog(@"image not already downloaded !");
                                                 [arrayIdsToBeDownloaded addObject:[dicProduct objectForKey:@"id"]];
                                                 [arrayUrlsToBeDownloaded addObject:[[dicProduct objectForKey:@"image"] objectForKey:@"src"]];
                                             }
                                         }
                                     }

                                     //DOWNLOAD IMAGES
                                     dispatch_async(dispatch_get_main_queue(), ^{

                                       if ([arrayIdsToBeDownloaded count] > 0) {
                                           [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                                       }

                                       [self hideLoading];
                                       [self.collectionView reloadData];
                                       //NSLog(@"test aaaaa");
                                     });

                                     for (NSString *id_ImageToDownload in arrayIdsToBeDownloaded) {
                                         //NSLog(@"download loop : %@", id_ImageToDownload);

                                         [self getImageWithImageUrl:[arrayUrlsToBeDownloaded objectAtIndex:[arrayIdsToBeDownloaded indexOfObject:id_ImageToDownload]]
                                                        andObjectId:id_ImageToDownload
                                                lastImageToDownload:YES    // does not matter
                                                 ImageForCollection:YES];  // modif
                                     }

                                     //set the new date
                                     self.loading = NO;
                                     [self saveTimeUpdateIPhone];
                                 }

                             } else {
                                 NSLog(@"error occured : %@", [error description]);
                                 self.activityLoading.hidden = YES;
                                 self.labelLoading.text = @"Please, connect to the \n internet or try later";
                             }
                           }];
}

#pragma mark request collections

- (void)makeRequestForPage:(int)pageNumber {
    self.loading = YES;

    __block NSMutableArray *arrayAddedOrModifiedCollections = [NSMutableArray new];
    NSString *website_string = [[NSUserDefaults standardUserDefaults] stringForKey:@"website_url"];
    NSString *collectionType = @"smart_collections";
    NSString *string_url = [NSString stringWithFormat:@"%@/admin/%@.json?published_status=published&page=%d&limit=250", website_string, collectionType, pageNumber];
    NSURL *url = [NSURL URLWithString:string_url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:token forHTTPHeaderField:@"X-Shopify-Access-Token"];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                             if (!error) {
                                 NSMutableDictionary *dicFromServer = [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] mutableCopy];
                                 //NSLog(@"all collections : %@ and count collections : %lu", [dicFromServer description], [[dicFromServer objectForKey:collectionType] count]);

                                 //CHECK COLLECTIONS ****************************************************
                                 arrayAddedOrModifiedCollections = [self arrayCollectionsWithInitialArray:arrayAddedOrModifiedCollections handleCollections:[dicFromServer objectForKey:@"smart_collections"] andCollectionType:@"smart_collections"];

                                 //ask for the custom collections
                                 NSString *collectionType_custom = @"custom_collections";
                                 NSString *string_url_custom = [NSString stringWithFormat:@"%@/admin/%@.json?published_status=published&page=%d&limit=250", website_string, collectionType_custom, 1];
                                 NSURL *url_custom = [NSURL URLWithString:string_url_custom];
                                 NSMutableURLRequest *request_custom = [[NSMutableURLRequest alloc] initWithURL:url_custom];
                                 [request_custom setValue:token forHTTPHeaderField:@"X-Shopify-Access-Token"];
                                 [NSURLConnection sendAsynchronousRequest:request_custom
                                                                    queue:[[NSOperationQueue alloc] init]
                                                        completionHandler:^(NSURLResponse *response_custom, NSData *data_custom, NSError *error_custom) {

                                                          if (!error_custom) {
                                                              NSMutableDictionary *dicFromServer_custom = [[NSJSONSerialization JSONObjectWithData:data_custom options:kNilOptions error:&error_custom] mutableCopy];
                                                              //NSLog(@"dicFromServer_custom : %@", [dicFromServer_custom description]);

                                                              //CHECK COLLECTIONS ****************************************************
                                                              arrayAddedOrModifiedCollections = [self arrayCollectionsWithInitialArray:arrayAddedOrModifiedCollections handleCollections:[dicFromServer_custom objectForKey:@"custom_collections"] andCollectionType:@"custom_collections"];
                                                          }

                                                          //check if no collection are available from the server ****************************************
                                                          if (count_collectionsToDownload == 0) {
                                                              //NSLog(@"display no display");
                                                              [self noCollectionAvailable];
                                                              return;
                                                          }

                                                          //GET THE PRODUCTS FOR EACH COLLECTION !  ****************************************************
                                                          for (NSDictionary *dicCollectionToDownload in arrayAddedOrModifiedCollections) {  // download products only for new/updated collections

                                                              if ([[dicCollections allKeys] count] > 0) {
                                                                  [NSThread sleepForTimeInterval:0.3f];
                                                              }

                                                              //NSLog(@"download products for new/updated collections");
                                                              NSString *collectionId = [NSString stringWithFormat:@"%@", [dicCollectionToDownload objectForKey:@"id"]];
                                                              [self getProductsInCollectionWithCollectionId:collectionId andPageNumber:1];
                                                          }
                                                        }];

                             } else {
                                 //NSLog(@"error occured : %@", [error description]);
                                 if ([dicCollections count] == 0) {
                                     self.activityLoading.hidden = YES;
                                     self.labelLoading.text = @"No Internet connection detected.";
                                     self.buttonReload.hidden = NO;

                                     self.loading = NO;
                                 }
                             }
                           }];
}

- (NSMutableArray *)arrayCollectionsWithInitialArray:(NSMutableArray *)arrayAddedOrModifiedCollections handleCollections:(NSArray *)arrayCollections andCollectionType:(NSString *)collectionType {
    NSArray *arrayCustomCollectionsIds = [[NSUserDefaults standardUserDefaults] objectForKey:@"arrayCustomCollectionsIds"];

    for (NSDictionary *dicCollection in arrayCollections) {
        //CUSTOM collections ******************************************************************************************
        //**************************************************************************************************************

        if ([arrayCustomCollectionsIds count] > 0 &&
            ![arrayCustomCollectionsIds containsObject:[dicCollection[@"id"] stringValue]]) {
            //NSLog(@"remove collection");
            continue;
        }
        //**************************************************************************************************************
        //**************************************************************************************************************

        [arrayAddedOrModifiedCollections addObject:dicCollection];
        [dic_Updated_Collections setObject:dicCollection forKey:[[dicCollection objectForKey:@"id"] stringValue]];
        count_collectionsToDownload++;
    }
    return arrayAddedOrModifiedCollections;
}

- (void)noCollectionAvailable {
    [self saveTimeUpdateIPhone];

    [dicCollections removeAllObjects];
    [dicProductsCorrespondingToCollections removeAllObjects];
    [self.collectionView reloadData];

    [NSUserDefaultsMethods removeFilesInFolderWithName:@"datasForProductsAndCollections"];
    [NSUserDefaultsMethods removeFilesInFolderWithName:@"datasForDicCollections"];

    dispatch_async(dispatch_get_main_queue(), ^{

      [self showLoading];
      self.imageBackgroundForLoading.hidden = NO;

      self.collectionView.hidden = YES;

      //        UILabel *labelNewTitleForProduct = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
      //        labelNewTitleForProduct.center = self.view.center;
      //        labelNewTitleForProduct.adjustsFontSizeToFitWidth = YES;
      //        labelNewTitleForProduct.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17.0f];
      //        labelNewTitleForProduct.textAlignment = UITextAlignmentCenter;
      //        labelNewTitleForProduct.numberOfLines = 2;
      //        labelNewTitleForProduct.text = @"This shop has no product yet, come back later !";
      //        [self.view addSubview:labelNewTitleForProduct];

      self.activityLoading.hidden = YES;
      self.labelLoading.text = @"This shop has no product yet, come back later !";
      self.buttonReload.hidden = NO;

      self.loading = NO;
    });
}

#pragma mark request products

- (void)getProductsInCollectionWithCollectionId:(NSString *)collection_id andPageNumber:(int)pageNumber {
    NSString *website_string = [[NSUserDefaults standardUserDefaults] stringForKey:@"website_url"];
    NSString *string_url = [NSString stringWithFormat:@"%@/admin/products.json?published_status=published&collection_id=%@&page=%d&limit=250", website_string, collection_id, pageNumber];
    NSURL *url = [NSURL URLWithString:string_url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setValue:token forHTTPHeaderField:@"X-Shopify-Access-Token"];
    [request setURL:url];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                             if (!error) {
                                 NSDictionary *dicFromServer_products = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                 NSArray *arrayForProducts = [dicFromServer_products objectForKey:@"products"];
                                 //NSLog(@"products : %@", [arrayForProducts description]);

                                 if ([arrayForProducts count] != 0) {  //check if the collection is empty

                                     //check if the collection exists in this dictionary and store it with the products
                                     if ([dic_Updated_ProductsCorrespondingToCollections objectForKey:collection_id]) {
                                         NSMutableArray *array = [[dic_Updated_ProductsCorrespondingToCollections objectForKey:collection_id] mutableCopy];
                                         [array addObjectsFromArray:arrayForProducts];
                                         [dic_Updated_ProductsCorrespondingToCollections setObject:array forKey:collection_id];

                                     } else {
                                         //NSLog(@"first time !");
                                         [dic_Updated_ProductsCorrespondingToCollections setObject:arrayForProducts forKey:collection_id];
                                     }
                                 } else if ([arrayForProducts count] == 0 && pageNumber == 1) {                                        // no products for this collection
                                     [dic_Updated_ProductsCorrespondingToCollections setObject:[NSArray array] forKey:collection_id];  // placeholder array
                                 }

                                 if ([arrayForProducts count] == 250) {  //we still have products to download for this collection
                                     [self getProductsInCollectionWithCollectionId:collection_id andPageNumber:(pageNumber + 1)];
                                 } else {  //all the products have been downloaded

                                     count_collectionsToDownload--;
                                     //NSLog(@"count_collectionsToDownload : %d", count_collectionsToDownload );

                                     //                if ([arrayForProducts count] == 0) {
                                     //NSLog(@"remove !!!");
                                     //                    [dic_Updated_Collections removeObjectForKey:collection_id];
                                     //                    [dic_Updated_ProductsCorrespondingToCollections removeObjectForKey:collection_id];
                                     //                    [sortedKeysForCategories removeObject:collection_id];
                                     //NSLog(@"delete collection for id : %@", collection_id);
                                     //                }else{

                                     if ([dic_Updated_ProductsCorrespondingToCollections[collection_id] count] > 0) {  //test if collection contains products

                                         //sort products by date of creation
                                         NSMutableArray *arrayProductsForSingleCollection = [dic_Updated_ProductsCorrespondingToCollections[collection_id] mutableCopy];
                                         NSArray *sortedArrayProducts = [arrayProductsForSingleCollection sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                           return [obj2[@"id"] compare:obj1[@"id"]];
                                         }];
                                         dic_Updated_ProductsCorrespondingToCollections[collection_id] = sortedArrayProducts;

                                         //check if the collection has been updated !!
                                         NSData *dicUpdateIPhone = [[NSUserDefaults standardUserDefaults] dataForKey:@"dateLastUpdateIPhone"];
                                         NSString *stringDateLastUpdateIPhone = [[NSKeyedUnarchiver unarchiveObjectWithData:dicUpdateIPhone] objectForKey:@"dateLastUpdateIPhone"];
                                         NSString *stringDateProductUpdate = [[dic_Updated_Collections objectForKey:collection_id] objectForKey:@"updated_at"];

                                         if ([self hasBeenUpdatedWithStringDateReference:stringDateLastUpdateIPhone andStringDate:stringDateProductUpdate]) {  //collection updated

                                             //check for a collection image
                                             if ([[dic_Updated_Collections objectForKey:collection_id] objectForKey:@"image"]) {
                                                 NSDictionary *dicCollection = [dic_Updated_Collections objectForKey:collection_id];

                                                 [self getImageWithImageUrl:[[dicCollection objectForKey:@"image"] objectForKey:@"src"]
                                                                andObjectId:collection_id
                                                        lastImageToDownload:YES
                                                         ImageForCollection:YES];
                                             } else {
                                                 //  download the first image of the first product
                                                 [self getImageWithImageUrl:[[[[dic_Updated_ProductsCorrespondingToCollections objectForKey:collection_id] firstObject] objectForKey:@"image"] objectForKey:@"src"]
                                                                andObjectId:[[[dic_Updated_ProductsCorrespondingToCollections objectForKey:collection_id] firstObject] objectForKey:@"id"]
                                                        lastImageToDownload:YES
                                                         ImageForCollection:YES];
                                             }
                                         }
                                     }

                                     if (count_collectionsToDownload == 0) {  //all collections have been downloaded -> save the date of download !

                                         [NSUserDefaultsMethods saveObjectInMemory:dic_Updated_ProductsCorrespondingToCollections toFolder:@"datasForProductsAndCollections"];
                                         [NSUserDefaultsMethods saveObjectInMemory:dic_Updated_Collections toFolder:@"datasForDicCollections"];

                                         //TAKE THE SERVER TO SCREEN !
                                         //                    dicCollections = [dic_Updated_Collections mutableCopy];
                                         //                    dicProductsCorrespondingToCollections = [dic_Updated_ProductsCorrespondingToCollections mutableCopy];
                                         //                    sortedKeysForCategories = [sorted_Updated_KeysForCategories mutableCopy];

                                         //                    dicCollections = [NSMutableDictionary dictionaryWithDictionary:[dic_Updated_Collections mutableCopy]];
                                         //                    dicProductsCorrespondingToCollections = [NSMutableDictionary dictionaryWithDictionary:[dic_Updated_ProductsCorrespondingToCollections mutableCopy]];
                                         //                    sortedKeysForCategories = [NSMutableArray arrayWithArray:[sorted_Updated_KeysForCategories mutableCopy]];

                                         dicCollections = [dic_Updated_Collections mutableCopy];
                                         dicProductsCorrespondingToCollections = [dic_Updated_ProductsCorrespondingToCollections mutableCopy];

                                         [self updateCollectionsThatCanBeDisplayed];

                                         //                    [dic_Updated_Collections removeAllObjects];
                                         //                    [dic_Updated_ProductsCorrespondingToCollections removeAllObjects];
                                         //                    [sorted_Updated_KeysForCategories removeAllObjects];
                                         //                    dic_Updated_Collections = [NSMutableDictionary new];
                                         //                    dic_Updated_ProductsCorrespondingToCollections = [NSMutableDictionary new];
                                         //                    sorted_Updated_KeysForCategories = [NSMutableArray new];

                                         if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == NO) {  //change

                                             [arrayProducts removeAllObjects];
                                             [dicProductsCorrespondingToCollections enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                               [arrayProducts addObjectsFromArray:obj];
                                             }];
                                             [self checkForProductsInSales];
                                         }

                                         //GET ALL IMAGES TO DOWNLOAD
                                         NSData *dicUpdateIPhone = [[NSUserDefaults standardUserDefaults] dataForKey:@"dateLastUpdateIPhone"];
                                         NSString *stringDateLastUpdateIPhone = [[NSKeyedUnarchiver unarchiveObjectWithData:dicUpdateIPhone] objectForKey:@"dateLastUpdateIPhone"];

                                         //get all unique images ! avoid to download each image several times !
                                         __block NSMutableArray *arrayIdsToBeDownloaded = [[NSMutableArray alloc] init];
                                         __block NSMutableArray *arrayUrlsToBeDownloaded = [[NSMutableArray alloc] init];

                                         for (NSString *key in [dicProductsCorrespondingToCollections allKeys]) {  //ENUMERATE ALL THE PRODUCTS TO KNOW IF UPDATED !
                                             for (NSDictionary *dicProduct in [dicProductsCorrespondingToCollections objectForKey:key]) {
                                                 NSString *stringDateProductUpdate = [dicProduct objectForKey:@"updated_at"];

                                                 if ([self hasBeenUpdatedWithStringDateReference:stringDateLastUpdateIPhone andStringDate:stringDateProductUpdate] || (                                                                                           // update !
                                                                                                                                                                          [ImageManagement getImageFromMemoryWithName:[dicProduct objectForKey:@"id"]] == nil &&  //first time !
                                                                                                                                                                          [dicProduct objectForKey:@"id"] != nil && [dicProduct objectForKey:@"image"] != nil)) {
                                                     if ([arrayIdsToBeDownloaded containsObject:[dicProduct objectForKey:@"id"]]) {  //objectId already to download !
                                                         //NSLog(@"image already downloaded !");
                                                         continue;
                                                     }

                                                     if ([dicProduct objectForKey:@"image"]) {
                                                         //NSLog(@"image not already downloaded !");
                                                         [arrayIdsToBeDownloaded addObject:[dicProduct objectForKey:@"id"]];
                                                         [arrayUrlsToBeDownloaded addObject:[[dicProduct objectForKey:@"image"] objectForKey:@"src"]];
                                                     }
                                                 }
                                             }
                                         }

                                         //DOWNLOAD IMAGES

                                         dispatch_async(dispatch_get_main_queue(), ^{

                                           if ([arrayIdsToBeDownloaded count] > 0) {
                                               [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                                           }
                                           if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == YES) {
                                               [self hideLoading];
                                               [self.collectionView reloadData];
                                               //NSLog(@"test aaaaa");
                                           }
                                         });

                                         for (NSString *id_ImageToDownload in arrayIdsToBeDownloaded) {
                                             [self getImageWithImageUrl:[arrayUrlsToBeDownloaded objectAtIndex:[arrayIdsToBeDownloaded indexOfObject:id_ImageToDownload]]
                                                            andObjectId:id_ImageToDownload
                                                    lastImageToDownload:NO    // does not matter
                                                     ImageForCollection:NO];  // modif
                                         }

                                         //EVERYTHING IS DOWNLOADED !
                                         [self saveTimeUpdateIPhone];
                                         self.loading = NO;
                                     }
                                 }
                             }
                           }];
}

#pragma mark images

- (void)getImageWithImageUrl:(NSString *)imageUrl andObjectId:(NSString *)objectId lastImageToDownload:(BOOL)isLastImmage ImageForCollection:(BOOL)isImageForCollection {
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void) {

      count_imagesToBeDownloaded++;
      //NSLog(@"count for dwnld image : %d", count_imagesToBeDownloaded);

      NSURL *urlForImage = [NSURL URLWithString:[imageUrl getShopifyUrlforSize:@"large"]];

      NSMutableURLRequest *request_image = [NSMutableURLRequest requestWithURL:urlForImage];
      [NSURLConnection sendAsynchronousRequest:request_image
                                         queue:[NSOperationQueue mainQueue]
                             completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                               if (error) {
                                   //NSLog(@"error in image dwnld: %@", [error description]);
                                   if (error.code == -1001 && [error.domain isEqualToString:@"NSURLErrorDomain"]) {
                                       [self getImageWithImageUrl:imageUrl andObjectId:objectId lastImageToDownload:NO ImageForCollection:isImageForCollection];
                                   }
                               }

                               count_imagesToBeDownloaded--;
                               //NSLog(@"count images to be downloaded after download : %d", count_imagesToBeDownloaded);

                               if (count_imagesToBeDownloaded == 0) {
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                                   if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == NO) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                         [self.collectionView reloadData];
                                         [self hideLoading];
                                         //NSLog(@"test image");
                                       });
                                   }
                               }

                               if (!error) {
                                   //save image in memory
                                   [ImageManagement saveImageWithData:data forName:objectId];

                                   //if the image is the first of a category : reloadData for collectionView
                                   if (isLastImmage == YES || isImageForCollection == YES) {  //Last ImageFromCollection is downloaded
                                       //NSLog(@"end download !");
                                       dispatch_async(dispatch_get_main_queue(), ^{

                                         UIImage *imahe = [ImageManagement getImageFromMemoryWithName:objectId];
                                         [self.collectionView reloadData];
                                       });
                                   }
                               }

                             }];
    });
}

#pragma mark other

- (BOOL)hasBeenUpdatedWithStringDateReference:(NSString *)stringDateReference andStringDate:(NSString *)stringDateToCompare {
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"];

    NSDate *dateToCompare = [dateFormat dateFromString:stringDateToCompare];
    NSDate *dateReference = [dateFormat dateFromString:stringDateReference];

    if ([dateToCompare timeIntervalSinceDate:dateReference] > 0 || stringDateReference == nil) {  //collection has to be updated in iPhone !
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];
    if (!success) {
        //NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (void)showLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.labelLoading.hidden = NO;
      self.activityLoading.hidden = NO;
      [self.activityLoading startAnimating];
      self.imageBackgroundForLoading.hidden = NO;
      self.viewForLabel.hidden = NO;
      self.collectionView.hidden = YES;
      self.buttonReload.hidden = YES;
    });
}

- (void)hideLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.labelLoading.hidden = YES;
      self.activityLoading.hidden = YES;
      [self.activityLoading stopAnimating];
      self.imageBackgroundForLoading.hidden = YES;
      self.viewForLabel.hidden = YES;
      self.collectionView.hidden = NO;
      self.buttonReload.hidden = YES;
    });
}

- (void)saveTimeUpdateIPhone {
    //save the date of the update in the iphone

    NSDate *date = [NSDate date];
    NSDateFormatter *anotherDateFormatter = [[NSDateFormatter alloc] init];
    anotherDateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [anotherDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"];
    //        NSString *dateWithFormat = [anotherDateFormatter stringFromDate:date];

    //date in a dictionary
    NSDictionary *dicDateUpdate = [NSDictionary dictionaryWithObjectsAndKeys:[anotherDateFormatter stringFromDate:date], @"dateLastUpdateIPhone", nil];

    NSData *DataForDateUpdate = [NSKeyedArchiver archivedDataWithRootObject:dicDateUpdate];  //save all the collections updated

    [[NSUserDefaults standardUserDefaults] setObject:DataForDateUpdate forKey:@"dateLastUpdateIPhone"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    //NSLog(@"date update - saved date : %@", [anotherDateFormatter stringFromDate:date]);
}

- (void)checkForProductsInSales {
    [arrayProducts enumerateObjectsUsingBlock:^(id dicProduct, NSUInteger idx, BOOL *stop) {

      [[dicProduct objectForKey:@"variants"] enumerateObjectsUsingBlock:^(id dicVariant, NSUInteger idx_variant, BOOL *stop) {

        if (![[dicVariant objectForKey:@"compare_at_price"] isKindOfClass:[NSNull class]]) {
            [arrayIndexesActiclesOnSales addObject:[NSNumber numberWithUnsignedInteger:idx]];
            *stop = YES;
        }
      }];

    }];
}

#pragma mark IBActions

- (IBAction)goLeft:(id)sender {
    //access the parent view controller
    self.stlmMainViewController = (ScrollViewController *)self.parentViewController.parentViewController;
    [self.stlmMainViewController pageLeft];
}

- (IBAction)goToCart:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard_autolayout" bundle:nil];
    CartViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"CartViewController"];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self presentViewController:vc1 animated:YES completion:nil];
    });
}
- (IBAction)reload:(id)sender {
    self.buttonReload.hidden = YES;
    self.labelLoading.text = @"Thank you for downloading our App!\n \nNow downloading the content, it should take less than a minute and only happen once. \n \nMake sure you are connected to the Internet !";
    [self showLoading];

    [Store fetchSettingsFromServer:self.fetchSettingsHandler];
}

#pragma mark collection View delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard_autolayout" bundle:nil];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == NO) {
        ProductDetailsViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"ProductDetailsViewController"];
        vc1.dicProduct = [arrayProducts objectAtIndex:indexPath.row];
        vc1.product_id = [vc1.dicProduct objectForKey:@"id"];
        vc1.image = [ImageManagement getImageFromMemoryWithName:vc1.product_id];
        [self.navigationController pushViewController:vc1 animated:YES];
    } else {
        CategoryProductsViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"CategoryProductsViewController"];

        if (indexPath.section == 0) {
            vc1.categoryName = [[self.featuredCollectionsForCV objectAtIndex:indexPath.row][@"shopify_collection_id"] stringValue];

            if ([dicCollections objectForKey:vc1.categoryName]) {
                vc1.collectionName = dicCollections[vc1.categoryName][@"title"];
                vc1.arrayProducts = dicProductsCorrespondingToCollections[vc1.categoryName];
                [self.navigationController pushViewController:vc1 animated:YES];
            }

        } else {
            vc1.categoryName = [[self.displayedCollectionsForCV objectAtIndex:indexPath.row][@"shopify_collection_id"] stringValue];

            if ([dicCollections objectForKey:vc1.categoryName]) {
                vc1.collectionName = dicCollections[vc1.categoryName][@"title"];
                vc1.arrayProducts = dicProductsCorrespondingToCollections[vc1.categoryName];
                [self.navigationController pushViewController:vc1 animated:YES];
            }
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.featuredCollectionsForCV count];
    } else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == NO) {
            return [arrayProducts count];
        } else {
            return [self.displayedCollectionsForCV count];
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == NO) {
        return 1;
    } else {
        return 2;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"cell created ");

    id<ProtocolCell> cell;

    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_FEATURED_IDENTIFIER forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == NO) {
        @try {
            NSString *product_id = [[arrayProducts objectAtIndex:indexPath.row] objectForKey:@"id"];
            cell.imageView.image = [ImageManagement getImageFromMemoryWithName:product_id];
        }
        @catch (NSException *exception) {
        }
        @finally {
        }

        if (cell.viewWhite.hidden == NO) {
            cell.viewWhite.hidden = YES;
            cell.displayLabel.hidden = YES;
        }

        if ([arrayIndexesActiclesOnSales containsObject:[NSNumber numberWithInteger:indexPath.row]]) {
            cell.imageViewSale.image = [UIImage imageNamed:@"icon-sale"];
        } else {
            cell.imageViewSale.image = nil;
        }

        return (UICollectionViewCell *)cell;

    } else {
        NSString *keyCategory;

        if (indexPath.section == 0) {  //featured collections

            keyCategory = [[self.featuredCollectionsForCV objectAtIndex:indexPath.row][@"shopify_collection_id"] stringValue];  // featured collections

        } else {
            keyCategory = [[self.displayedCollectionsForCV objectAtIndex:indexPath.row][@"shopify_collection_id"] stringValue];  // displayed collections
        }

        cell.displayLabel.text = dicCollections[keyCategory][@"title"];

        UIColor *color = [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorViewTitleCollection"] objectForKey:@"red"] floatValue] / 255
                                         green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorViewTitleCollection"] objectForKey:@"green"] floatValue] / 255
                                          blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorViewTitleCollection"] objectForKey:@"blue"] floatValue] / 255
                                         alpha:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorViewTitleCollection"] objectForKey:@"alpha"] floatValue]];
        cell.viewWhite.backgroundColor = color;

        //        if (cell.viewWhite.hidden) {
        //            cell.viewWhite.hidden = NO;
        //            cell.displayLabel.hidden = NO;
        //        }

        //check for specific collection image
        UIImage *collectionImage = [ImageManagement getImageFromMemoryWithName:keyCategory];
        if (collectionImage != nil) {
            cell.imageView.image = [ImageManagement getImageFromMemoryWithName:keyCategory];
        } else {  //take the fist product image available

            for (NSDictionary *dicProduct in [dicProductsCorrespondingToCollections objectForKey:keyCategory]) {
                NSString *productId = [dicProduct objectForKey:@"id"];

                if ([ImageManagement getImageFromMemoryWithName:productId] != nil) {
                    cell.imageView.image = [ImageManagement getImageFromMemoryWithName:productId];
                    break;
                }
            }
        }
        return (UICollectionViewCell *)cell;
    }
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 3 : 2;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? CGSizeMake(100, 50) : CGSizeMake(50, 50);
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];

        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        layout.headerHeight = 0;
        layout.footerHeight = 0;
        layout.minimumColumnSpacing = 5;
        layout.minimumInteritemSpacing = 5;

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor colorWithRed:235.0f / 255.0f
                                                          green:235.0f / 255.0f
                                                           blue:235.0f / 255.0f
                                                          alpha:1.0f];

        [_collectionView registerClass:[CHTCollectionViewWaterfallCell class]
            forCellWithReuseIdentifier:CELL_IDENTIFIER];
        [_collectionView registerClass:[CHTCollectionViewWaterfallCell class]
            forCellWithReuseIdentifier:CELL_FEATURED_IDENTIFIER];
    }
    return _collectionView;
}

@end