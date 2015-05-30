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

#import "ProductsDownlaodOperation.h"
#import "CollectionsDownloaderOperation.h"

#import "CollectionsHelper.h"

@interface CategoriesViewController ()

//IBOUTLETS
@property(strong, nonatomic) IBOutlet UIBarButtonItem *navBarButtonLeft;
@property(strong, nonatomic) IBOutlet UIBarButtonItem *buttonCart;

@property(strong, nonatomic) IBOutlet UIView *viewError;
@property(strong, nonatomic) IBOutlet UIView *viewNavBar;

@property(strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property(strong, nonatomic) IBOutlet UILabel *labelLoading;
@property(strong, nonatomic) IBOutlet UIActivityIndicatorView *activityLoading;
@property(strong, nonatomic) IBOutlet UIImageView *imageBackgroundForLoading;
@property(strong, nonatomic) IBOutlet UIButton *buttonReload;

@property(strong, nonatomic) UICollectionView *collectionView;
@property(nonatomic, strong) ScrollViewController *stlmMainViewController;
@property(strong, nonatomic) UIRefreshControl *refreshControl;

//GLOBAL PROPERTIES
@property(nonatomic) __block BOOL loading;

@property(nonatomic, strong) __block NSArray *displayedCollectionsForCV;  //arrays that have to be displayed ( collections + products downloaded )
@property(nonatomic, strong) __block NSArray *featuredCollectionsForCV;

@property(nonatomic, strong) __block NSOperationQueue *productsOperationQueue;
@property(nonatomic, strong) __block NSOperationQueue *collectionsOperationQueue;

@property(nonatomic) __block NSInteger collectionProductsToDownload;
@end

#define CELL_IDENTIFIER @"WaterfallCell"
#define CELL_FEATURED_IDENTIFIER @"CHTCollectionViewWaterfallFeaturedCell"

const NSString *loadingMessage = @"Thank you for downloading our App!\n \nNow downloading the content, it should take less than a minute and only happen once. \n \nMake sure you are connected to the Internet !";
const NSString *noInternetConnectionMessage = @"It seems you are not connected to the internet... \nReconnect and try again :)";
const NSString *noCollectionToDisplayMessage = @"This shop has no product yet, come back later !";

@implementation CategoriesViewController {
    __block NSString *token;

    __block NSMutableArray *arrayProducts;
    __block NSMutableArray *array_Updated_Products;
    __block NSMutableArray *arrayIndexesActiclesOnSales;

    __block NSDictionary *dicProductsCorrespondingToCollections;
    __block NSDictionary *dicCollections;

    __block int count_imagesToBeDownloaded;
}

#pragma mark - ViewLifeCycle

- (void)viewWillDisappear:(BOOL)animated {
    [self.stlmMainViewController disableScrollView];
}

- (void)viewWillAppear:(BOOL)animated {
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

    self.viewError.layer.cornerRadius = 5;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePhoneSettings:)
                                                 name:@"updatePhoneSettings"
                                               object:nil];

    [[self navigationController] setNavigationBarHidden:YES animated:YES];  //do not remove

    self.stlmMainViewController = (ScrollViewController *)self.parentViewController.parentViewController;

    self.productsOperationQueue = [[NSOperationQueue alloc] init];
    self.productsOperationQueue.maxConcurrentOperationCount = 1;

    self.collectionsOperationQueue = [[NSOperationQueue alloc] init];
    self.collectionsOperationQueue.maxConcurrentOperationCount = 1;

    count_imagesToBeDownloaded = 0;

    CGRect frame = self.collectionView.frame;
    frame.origin.y = 64;
    frame.size.height = self.view.frame.size.height - 64;
    self.collectionView.frame = frame;
    [self.view addSubview:self.collectionView];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.collectionView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(reloadCollectionView) forControlEvents:UIControlEventValueChanged];

    array_Updated_Products = [[NSMutableArray alloc] init];
    arrayIndexesActiclesOnSales = [[NSMutableArray alloc] init];

    dispatch_sync(dispatch_get_global_queue(0, 0), ^{

      if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == NO) {
          arrayProducts = [[NSUserDefaultsMethods getObjectFromMemoryInFolder:@"arrayProducts"] mutableCopy];

          if (arrayProducts != nil) {
              [self checkForProductsInSales];
              dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                [self stopLoadingToDisplayCollections];
              });
          } else {
              arrayProducts = [NSMutableArray new];
              [self showLoadingStateWithMessage:loadingMessage];
          }

      } else {
          dicCollections = [NSUserDefaultsMethods getObjectFromMemoryInFolder:@"datasForDicCollections"];
          dicProductsCorrespondingToCollections = [NSUserDefaultsMethods getObjectFromMemoryInFolder:@"datasForProductsAndCollections"];

          if (dicCollections != nil && dicProductsCorrespondingToCollections != nil) {
              [self updateCollectionsThatCanBeDisplayed];

              dispatch_async(dispatch_get_main_queue(), ^{
                [self stopLoadingToDisplayCollections];
              });

          } else {
              [self showLoadingStateWithMessage:loadingMessage];
          }
      }

      [Store fetchSettingsFromServerAndForceShopifyUpdate:YES];
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

#pragma mark - NSNotifications

- (void)updatePhoneSettings:(NSNotification *)notification {
    if (!notification.userInfo[@"error"]) {
        token = [[NSUserDefaults standardUserDefaults] objectForKey:@"shopifyToken"];
        [self updateColors];

        [self updateCollectionsThatCanBeDisplayed];

        if (self.loading == NO && [notification.userInfo[@"forceShopifyUpdate"] boolValue] == YES) {  //we force the download of Shopify
            [self downloadCollectionsAndProducts];
        } else if (self.loading == NO && [notification.userInfo[@"forceShopifyUpdate"] boolValue] == NO) {
            if ([CollectionsHelper isMissingCollectionsInMemoryToDisplayWithProducts:[dicProductsCorrespondingToCollections copy] collections:[dicCollections copy]]) {
                [self downloadCollectionsAndProducts];
            }
        }
    } else {
        if ([dicCollections count] == 0) {
            [self showErrorViewWithMessage:noInternetConnectionMessage];
        }
    }
}

#pragma mark - Collections Downloader

- (void)downloadCollectionsAndProducts {
    self.loading = YES;
    self.collectionProductsToDownload = 0;

    [self.collectionsOperationQueue cancelAllOperations];
    [self.productsOperationQueue cancelAllOperations];

    __weak typeof(self) wSelf = self;
    CollectionsDownloaderOperation *collectionsDownloaderOperation =
        [[CollectionsDownloaderOperation alloc] initWithToken:token
                                              completionBlock:^(NSArray *collections, NSError *error) {

                                                if (!error) {
                                                    NSLog(@"download colledction main th : %d", [NSThread isMainThread]);
                                                    NSArray *wantedCollections = [CollectionsHelper collectionsToKeepFromServerWithInitialArray:collections];

                                                    //check if no collection are available from the server ****************************************
                                                    if (wantedCollections.count == 0) {
                                                        [wSelf noCollectionAvailable];
                                                        wSelf.loading = NO;
                                                        return;
                                                    } else {
                                                        NSDictionary *transformedCollections = [CollectionsHelper fromArrayToDictionary:wantedCollections];
                                                        [wSelf getProductsForCollections:transformedCollections];
                                                    }

                                                } else {
                                                    wSelf.loading = NO;
                                                    if ([dicCollections count] == 0) [wSelf showErrorViewWithMessage:noInternetConnectionMessage];
                                                }
                                              }];

    [self.collectionsOperationQueue addOperation:collectionsDownloaderOperation];
}

#pragma mark - Collections Manegement

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
        if ([dicCollections objectForKey:[collection[@"shopify_collection_id"] stringValue]] &&
            [dicProductsCorrespondingToCollections objectForKey:[collection[@"shopify_collection_id"] stringValue]]) {
            [updatedDisplayedCollectionsForCV addObject:collection];
        }
    }

    //display all the featured collections we have in memeory
    NSMutableArray *updatedFeaturedCollectionsForCV = [[NSMutableArray alloc] init];
    for (NSDictionary *collection in featuredCollectionsFromServer) {
        if ([dicCollections objectForKey:[collection[@"shopify_collection_id"] stringValue]] &&
            [dicProductsCorrespondingToCollections objectForKey:[collection[@"shopify_collection_id"] stringValue]]) {
            [updatedFeaturedCollectionsForCV addObject:collection];
        }
    }

    //sort collections
    updatedDisplayedCollectionsForCV = [CollectionsHelper sortCollectionsInArray:updatedDisplayedCollectionsForCV];
    updatedFeaturedCollectionsForCV = [CollectionsHelper sortCollectionsInArray:updatedFeaturedCollectionsForCV];

    self.displayedCollectionsForCV = [updatedDisplayedCollectionsForCV copy];
    self.featuredCollectionsForCV = [updatedFeaturedCollectionsForCV copy];

    dispatch_async(dispatch_get_main_queue(), ^{
      [self.collectionView reloadData];
    });
}

#pragma mark - Products Downloader

- (void)getProductsForCollections:(NSDictionary *)collections {
    __block NSMutableDictionary *updatedProducts = [[NSMutableDictionary alloc] init];
    __block NSInteger countCollectionsToDownload = [collections allKeys].count;

    void (^blockName)(NSArray *, NSString *, NSError *) = ^void(NSArray *products, NSString *collectionId, NSError *error) {

      if (products) updatedProducts[collectionId] = products;

      countCollectionsToDownload--;

      if ([updatedProducts[collectionId] count] > 0) {  //test if collection contains products

          //sort products by date of creation
          NSMutableArray *arrayProductsForSingleCollection = [updatedProducts[collectionId] mutableCopy];
          NSArray *sortedArrayProducts = [arrayProductsForSingleCollection sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj2[@"id"] compare:obj1[@"id"]];
          }];
          updatedProducts[collectionId] = sortedArrayProducts;
      }

      //check if the collection has been updated !!
      NSData *dicUpdateIPhone = [[NSUserDefaults standardUserDefaults] dataForKey:@"dateLastUpdateIPhone"];
      NSString *stringDateLastUpdateIPhone = [[NSKeyedUnarchiver unarchiveObjectWithData:dicUpdateIPhone] objectForKey:@"dateLastUpdateIPhone"];
      NSString *stringDateProductUpdate = [[collections objectForKey:collectionId] objectForKey:@"updated_at"];

      if ([ImageManagement getImageFromMemoryWithName:collectionId] == nil ||
          [self hasBeenUpdatedWithStringDateReference:stringDateLastUpdateIPhone
                                        andStringDate:stringDateProductUpdate]) {  //collection updated

          //check for a collection image
          if ([collections[collectionId] objectForKey:@"image"]) {
              [self getImageWithImageUrl:collections[collectionId][@"image"][@"src"]
                             andObjectId:collectionId
                     lastImageToDownload:YES
                      ImageForCollection:YES];
          }
      }

      if (countCollectionsToDownload == 0) {
          NSLog(@"done !");
          [self downloadIsFinishedWithCollections:collections products:updatedProducts];
      }

    };

    //GET THE PRODUCTS FOR EACH COLLECTION !  ****************************************************
    for (NSString *collectionId in [collections allKeys]) {  // download products only for new/updated collections

        ProductsDownlaodOperation *productsOperation = [[ProductsDownlaodOperation alloc]
            initWithCollectionId:collectionId
                           token:token
                 completionBlock:blockName];

        [self.productsOperationQueue addOperation:productsOperation];

        //add a waiting queue
        [self.productsOperationQueue addOperationWithBlock:^{
          [NSThread sleepForTimeInterval:0.3f];
        }];
    }
}

- (void)downloadIsFinishedWithCollections:(NSDictionary *)collections products:(NSDictionary *)products {
    [NSUserDefaultsMethods saveObjectInMemory:products toFolder:@"datasForProductsAndCollections"];
    [NSUserDefaultsMethods saveObjectInMemory:collections toFolder:@"datasForDicCollections"];

    dicCollections = [collections copy];
    dicProductsCorrespondingToCollections = [products copy];

    [self updateCollectionsThatCanBeDisplayed];

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
    NSMutableDictionary *productImagesToDownload = [[NSMutableDictionary alloc] init];

    for (NSString *key in dicProductsCorrespondingToCollections.allKeys) {  //ENUMERATE ALL THE PRODUCTS TO KNOW IF UPDATED !
        for (NSDictionary *dicProduct in dicProductsCorrespondingToCollections[key]) {
            NSString *stringDateProductUpdate = [dicProduct objectForKey:@"updated_at"];

            if (![productImagesToDownload.allKeys containsObject:[dicProduct objectForKey:@"id"]] &&
                ([self hasBeenUpdatedWithStringDateReference:stringDateLastUpdateIPhone andStringDate:stringDateProductUpdate] ||
                 ([ImageManagement getImageFromMemoryWithName:[dicProduct objectForKey:@"id"]] == nil &&  //first time !
                  [dicProduct objectForKey:@"id"] != nil && [dicProduct objectForKey:@"image"] != nil))) {
                if ([dicProduct objectForKey:@"image"]) {
                    productImagesToDownload[[dicProduct[@"id"] stringValue]] = dicProduct[@"image"][@"src"];
                }
            }
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{

      if (productImagesToDownload.allKeys.count > 0) {
          [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
      }
      if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == YES) {
          [self stopLoadingToDisplayCollections];
          //                    [self.collectionView reloadData];
          //NSLog(@"test aaaaa");
      }
    });

    for (NSString *productId in productImagesToDownload.allKeys) {
        [self getImageWithImageUrl:productImagesToDownload[productId]
                       andObjectId:productId
               lastImageToDownload:NO    // does not matter
                ImageForCollection:NO];  // modif
    }

    //EVERYTHING IS DOWNLOADED !
    [self saveTimeUpdateIPhone];
    self.loading = NO;
}

#pragma mark - Image Downloader

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
                                         [self stopLoadingToDisplayCollections];
                                         //NSLog(@"test image");
                                       });
                                   }
                               }

                               if (!error) {
                                   //save image in memory
                                   [ImageManagement saveImageWithData:data forName:objectId];

                                   //if the image is the first of a category : reloadData for collectionView
                                   if (isLastImmage == YES || isImageForCollection == YES) {  //Last ImageFromCollection is downloaded
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                         [self.collectionView reloadData];
                                       });
                                   }
                               }

                             }];
    });
}

#pragma mark - UI

- (void)showErrorViewWithMessage:(const NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.labelLoading.text = errorMessage;
      self.collectionView.hidden = YES;
      self.viewError.hidden = NO;

      self.imageBackgroundForLoading.hidden = NO;
      self.viewError.hidden = NO;
      self.activityLoading.hidden = YES;
      [self.activityLoading stopAnimating];
      self.buttonReload.hidden = NO;
    });
}

- (void)showLoadingStateWithMessage:(const NSString *)loadingMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.labelLoading.text = loadingMessage;
      self.collectionView.hidden = YES;
      self.viewError.hidden = NO;

      self.activityLoading.hidden = NO;
      [self.activityLoading startAnimating];
      self.imageBackgroundForLoading.hidden = NO;
      self.buttonReload.hidden = YES;
    });
}

- (void)noCollectionAvailable {
    [self saveTimeUpdateIPhone];

    [self.collectionView reloadData];

    [self showErrorViewWithMessage:noCollectionToDisplayMessage];
}

- (void)stopLoadingToDisplayCollections {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.collectionView.hidden = NO;
      self.viewError.hidden = YES;
    });
}

- (void)updateColors {
    dispatch_async(dispatch_get_main_queue(), ^{

      self.viewNavBar.backgroundColor = [self colorFromMemoryWithName:@"colorNavBar"];

      [self.navBar setBarTintColor:self.viewNavBar.backgroundColor];

      [AppDelegate setAppearance];

      [self.collectionView reloadData];
    });
}

#pragma mark - Date

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

#pragma mark - Other

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

#pragma mark - Helpers

- (UIColor *)colorFromMemoryWithName:(NSString *)colorName {
    return [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:colorName] objectForKey:@"red"] floatValue] / 255
                           green:[[[[NSUserDefaults standardUserDefaults] objectForKey:colorName] objectForKey:@"green"] floatValue] / 255
                            blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:colorName] objectForKey:@"blue"] floatValue] / 255
                           alpha:[[[[NSUserDefaults standardUserDefaults] objectForKey:colorName] objectForKey:@"alpha"] floatValue]];
}

#pragma mark - IBActions

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
    [self showLoadingStateWithMessage:loadingMessage];

    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
      [Store fetchSettingsFromServerAndForceShopifyUpdate:YES];
    });
}

#pragma mark - CollectionView

- (void)reloadCollectionView {
    [self.refreshControl endRefreshing];

    if (self.loading == NO) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == YES) {
            [Store fetchSettingsFromServerAndForceShopifyUpdate:YES];
        } else {
            [array_Updated_Products removeAllObjects];
        }
    }
}

#pragma mark - UICollectionViewDelegate

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
        @try {
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
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<ProtocolCell> cell;

    //    NSLog(@"cell indexpath : %@", [indexPath description]);
    //    NSLog(@"cell collections to display : %d", self.displayedCollectionsForCV.count);

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
        @try {
            if (indexPath.section == 0) {
                keyCategory = [[self.featuredCollectionsForCV objectAtIndex:indexPath.row][@"shopify_collection_id"] stringValue];  // featured collections
            } else {
                keyCategory = [[self.displayedCollectionsForCV objectAtIndex:indexPath.row][@"shopify_collection_id"] stringValue];  // displayed collections
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }

        cell.displayLabel.text = dicCollections[keyCategory][@"title"];
        cell.viewWhite.backgroundColor = [self colorFromMemoryWithName:@"colorViewTitleCollection"];

        //check for specific collection image
        UIImage *collectionImage = [ImageManagement getImageFromMemoryWithName:keyCategory];
        if (collectionImage) {
            cell.imageView.image = collectionImage;
        } else {
            cell.imageView.image = nil;
            cell.imageView.backgroundColor = [self colorFromMemoryWithName:@"colorViewTitleCollection"];
        }

        return (UICollectionViewCell *)cell;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //    NSLog(@"numberOfItemsInSection featured : %lu", (unsigned long)[self.featuredCollectionsForCV count]);
    //    NSLog(@"datasource collections to display : %d", self.displayedCollectionsForCV.count);

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
        [_collectionView registerClass:[CHTCollectionViewWaterfallFeaturedCell class]
            forCellWithReuseIdentifier:CELL_FEATURED_IDENTIFIER];
    }
    return _collectionView;
}

#pragma mark - unused
#pragma mark - Products Only Downloader

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

                                       [self stopLoadingToDisplayCollections];
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

@end