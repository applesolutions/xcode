//
//  CategoriesViewController.m
//  208
//
//  Created by amaury soviche on 30/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "CategoriesViewController.h"

#import "CHTCollectionViewWaterfallCell.h"
#import "CHTCollectionViewWaterfallHeader.h"
#import "CHTCollectionViewWaterfallFooter.h"

#import "ProductDetailsViewController.h"
#import "CartViewController.h"
#import "ScrollViewController.h"
#import "CategoryProductsViewController.h"

#import "ImageManagement.h"
#import "NSString+URL_Shopify.h"

@interface CategoriesViewController ()

@property (strong, nonatomic) UICollectionView *collectionView;

@property (nonatomic, strong) ScrollViewController *stlmMainViewController;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonCart;
@property (strong, nonatomic) IBOutlet UILabel *labelLoading;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityLoading;
@property (strong, nonatomic) IBOutlet UIImageView *imageBackgroundForLoading;
@property (strong, nonatomic) IBOutlet UIView *viewForLabel;

@property (strong, nonatomic) IBOutlet UIView *ViewNavBar;
@end

#define CELL_IDENTIFIER @"WaterfallCell"
#define HEADER_IDENTIFIER @"WaterfallHeader"
#define FOOTER_IDENTIFIER @"WaterfallFooter"

@implementation CategoriesViewController{
    
    NSString *website_string;
    NSString *token;
    
    __block NSMutableArray *arrayProducts;
    
    __block NSMutableDictionary *dicProductsCorrespondingToCollections;
    __block NSMutableDictionary *dicCollections;
    
    __block NSMutableArray *arrayTempProductsFormServer;
    __block NSMutableArray *sortedKeysForCategories;
    __block NSMutableArray *arrayIndexesActiclesOnSales;
    
    __block int count_collectionsToDownload;
    __block int count_imagesToBeDownloaded;
    
    __block NSMutableArray *arrayIdsToBeDownloaded_checkForMissingImages; //array to remember the images to downlaod
}

#pragma mark ViewLifeCycle

-(void) viewWillDisappear:(BOOL)animated{
    self.stlmMainViewController= (ScrollViewController *) self.parentViewController.parentViewController;
    [self.stlmMainViewController disableScrollView];
}

-(void) viewWillAppear:(BOOL)animated{
    
    self.stlmMainViewController= (ScrollViewController *) self.parentViewController.parentViewController;
    [self.stlmMainViewController enableScrollView];
    
    NSData *dataFromMemory = [[NSUserDefaults standardUserDefaults] dataForKey: @"arrayProductsInCart"];
    
    if([[NSKeyedUnarchiver unarchiveObjectWithData:dataFromMemory] count] == 0 ){
        
        self.buttonCart.image =[[UIImage imageNamed:@"nav-icon-cart"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }else{
        self.buttonCart.image =[[UIImage imageNamed:@"nav-icon-cart-full"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    [self.collectionView reloadData];
    
    self.ViewNavBar.backgroundColor =
        [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"red"] floatValue] / 255
                        green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"green"] floatValue] / 255
                         blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"blue"] floatValue] / 255
                        alpha:1];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    count_imagesToBeDownloaded = 0;
    
    CGRect frame = self.collectionView.frame;
    frame.origin.y = 64;
    frame.size.height = self.view.frame.size.height - 64;
    self.collectionView.frame = frame;
    
    [self.view addSubview:self.collectionView];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        
        arrayProducts = [NSMutableArray new];
        
        arrayTempProductsFormServer = [[NSMutableArray alloc] init];
        sortedKeysForCategories = [NSMutableArray new];
        arrayIndexesActiclesOnSales = [NSMutableArray new];
        
        website_string = [[NSUserDefaults standardUserDefaults] stringForKey:@"website_url"];
        token = [[NSUserDefaults standardUserDefaults] stringForKey:@"shopify_token"];
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:@"datasForProductsAndCollections"];
        NSString *imagePath_collections =[documentsDirectory stringByAppendingPathComponent:@"datasForDicCollections"];
        
        NSData *dataTest = [NSData dataWithContentsOfFile:imagePath];
        NSData *dataTest_collections = [NSData dataWithContentsOfFile:imagePath_collections];
        
        
        
        if ( dataTest != nil && dataTest_collections != nil ) {
            
            dicCollections = [[NSKeyedUnarchiver unarchiveObjectWithData:dataTest_collections] mutableCopy];
            dicProductsCorrespondingToCollections  =  [[NSKeyedUnarchiver unarchiveObjectWithData:dataTest] mutableCopy];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == NO) {
                
                [dicProductsCorrespondingToCollections enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [arrayProducts addObjectsFromArray:obj];
                }];
                [self checkForProductsInSales];
            }
            
            NSLog(@"array products : %@", [dicCollections description]);
            //            NSLog(@"products : %@", [dicProductsCorrespondingToCollections description]);
            
            sortedKeysForCategories = [[[dicProductsCorrespondingToCollections allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                return [[[dicCollections objectForKey:a] objectForKey:@"title"] compare:[[dicCollections objectForKey:b] objectForKey:@"title"]];
            }] mutableCopy];
            
            [self.collectionView reloadData];
            
            [self hideLoading];

            
            [self checkForMissingImages];
            
            
        }else{
            dicProductsCorrespondingToCollections = [NSMutableDictionary new];
            dicCollections = [[NSMutableDictionary alloc] init];
            [self showLoading];
        }
        
        [self makeRequestForPage:1];
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //DO NOT BACK UP THE DATAS INTO ICLOUD
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSURL *pathURL= [NSURL fileURLWithPath:documentsDirectory];
        [self addSkipBackupAttributeToItemAtURL:pathURL];
        
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *folder = [path objectAtIndex:0];
        NSURL *pathURLUserDef= [NSURL fileURLWithPath:folder];
        [self addSkipBackupAttributeToItemAtURL:pathURLUserDef];
    });
}

#pragma mark request collections

-(void) makeRequestForPage: (int) pageNumber{
    
    NSLog(@"last update at time : %@",  [[NSUserDefaults standardUserDefaults] objectForKey:@"dateLastUpdateIPhone"]);
    NSString *collectionType = [[NSUserDefaults standardUserDefaults] stringForKey:@"collectionType"];
    //     NSString *collectionType = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"dicUser"] objectForKey:@"collectionType"];
    
    //ask for the published collections
    NSString *string_url =  [NSString stringWithFormat:@"%@/admin/%@.json?published_status=published&page=%d&limit=250", website_string, collectionType, pageNumber];
    
    NSLog(@"complete url : %@", string_url);
    NSURL *url = [NSURL URLWithString:string_url];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:token forHTTPHeaderField:@"X-Shopify-Access-Token"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if (!error){
            
            NSDictionary* dicFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            //            NSLog(@"all collections : %@ and count collections : %lu", [dicFromServer description], [[dicFromServer objectForKey:collectionType] count]);
            //            NSLog(@"dic collections from memory : %@", [dicCollections description]);
            
            dispatch_sync(dispatch_get_global_queue(0, 0), ^{
                
                //CHECK FOR ADDED/MODIFIED COLLECTIONS ****************************************************
                NSMutableArray *arrayAddedOrModifiedCollections = [NSMutableArray new];
                
                for (NSDictionary *dicCollection in [dicFromServer objectForKey:collectionType]) {
                    
                    if ( ! [[dicCollections allKeys] containsObject: [[dicCollection objectForKey:@"id"] stringValue] ] ||
                        ! [[dicProductsCorrespondingToCollections allKeys] containsObject:[[dicCollection objectForKey:@"id"] stringValue]]) { //collection added since last update
                        NSLog(@"add collection to memory");
                        [arrayAddedOrModifiedCollections addObject:dicCollection];
                        [dicCollections setObject:dicCollection forKey: [[dicCollection objectForKey:@"id"] stringValue]];
                    }
                    else{ //check for update
                        
                        NSLog(@"compare dates");
                        NSString *string_dateUpdate = [dicCollection objectForKey:@"updated_at"];
                        
                        NSData *dicUpdateIPhone = [[NSUserDefaults standardUserDefaults] dataForKey:@"dateLastUpdateIPhone"];
                        NSString * string_dateLastUpdateIPhone = [[NSKeyedUnarchiver unarchiveObjectWithData:dicUpdateIPhone] objectForKey:@"dateLastUpdateIPhone"];
                        
                        NSLog(@"date 1 : %@ and date update iPhone : %@", string_dateUpdate, string_dateLastUpdateIPhone);
                        
                        // Convert string to date object
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        dateFormat.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
                        [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"];
                        
                        NSDate *dateUpdate = [dateFormat dateFromString:string_dateUpdate];
                        NSDate *dateLastUpdateIPhone = [dateFormat dateFromString:string_dateLastUpdateIPhone];
                        
                        NSLog(@"update diff : %f",[dateUpdate timeIntervalSinceDate:dateLastUpdateIPhone] );
                        if ([dateUpdate timeIntervalSinceDate:dateLastUpdateIPhone] > 0) { //collection has to be updated in iPhone !
                            NSLog(@"update !!");
                            
                            [arrayAddedOrModifiedCollections addObject:dicCollection];
                            [dicCollections setObject:dicCollection forKey:[[dicCollection objectForKey:@"id"] stringValue]];
                        }
                    }
                }
                count_collectionsToDownload = (int)[arrayAddedOrModifiedCollections count];
                
                //CHECK FOR DELETED COLLECTIONS *****************************************************************
                
                //check if no collection are available from the server
                if ([[dicFromServer objectForKey:collectionType] count] == 0) {
                    
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"dicProductsCorrespondingToCollections"];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"dicCollections"];
                    
                    //                    [[NSUserDefaults standardUserDefaults] synchronize]; // uncom
                    
                    [self saveTimeUpdateIPhone];
                    
                    [dicCollections removeAllObjects];
                    [dicProductsCorrespondingToCollections removeAllObjects];
                    [sortedKeysForCategories removeAllObjects];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.collectionView reloadData];
                        [self hideLoading];
                        NSLog(@"test aaaaa");
                        self.collectionView.hidden= YES;
                        
                        UILabel *labelNewTitleForProduct = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
                        labelNewTitleForProduct.center = self.view.center;
                        labelNewTitleForProduct.adjustsFontSizeToFitWidth = YES;
                        labelNewTitleForProduct.font = [UIFont fontWithName:@"ProximaNova-SemiBold" size:17.0f];
                        labelNewTitleForProduct.textAlignment = UITextAlignmentCenter;
                        labelNewTitleForProduct.numberOfLines = 2;
                        labelNewTitleForProduct.text = @"This shop has no product yet, come back later !";
                        [self.view addSubview:labelNewTitleForProduct];
                    });
                    return;
                }
                
                NSMutableArray *arrayDeleteCollections = [NSMutableArray new];
                for (NSString *CollectionIdInMemory in [dicCollections allKeys]) { //loop in memory
                    
                    for (NSDictionary *dicCollection in [dicFromServer objectForKey:collectionType]) { //loop in server
                        
                        NSString *id_collection_in_server = [[dicCollection objectForKey:@"id"] stringValue];
                        
                        if ([CollectionIdInMemory isEqualToString:id_collection_in_server]) {
                            NSLog(@"break");
                            break;
                        }
                        
                        else if ([[[dicFromServer objectForKey:collectionType] lastObject] isEqualToDictionary:dicCollection] &&
                                 ! [ CollectionIdInMemory isEqualToString:id_collection_in_server]) { //check for last object in array
                            
                            NSLog(@"delete !");
                            [arrayDeleteCollections addObject:CollectionIdInMemory];
                            
                            for (NSDictionary *dicProduct in [dicProductsCorrespondingToCollections objectForKey:CollectionIdInMemory]) { // delete images
                                [ImageManagement deleteImageInMemoryWithName:[[dicProduct objectForKey:@"id"] stringValue]];
                            }
                        }
                    }
                }
                if ([arrayDeleteCollections count] > 0 ) {
                    [dicCollections removeObjectsForKeys:arrayDeleteCollections];
                    [dicProductsCorrespondingToCollections removeObjectsForKeys:arrayDeleteCollections];
                    [sortedKeysForCategories removeObjectsInArray:arrayDeleteCollections];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.collectionView reloadData];
                    });
                }
                
                //                NSLog(@"dic collections : %@", dicCollections);
                //                NSLog(@"added or modified array : %@" , [arrayAddedOrModifiedCollections description]);
                
                
                NSLog(@"count for collections : %d", count_collectionsToDownload);
                
                int numberProductAtActualPage = (int)[[dicFromServer objectForKey:collectionType] count];
                if (numberProductAtActualPage == 250){
                    
                    [self makeRequestForPage:(pageNumber + 1 )];
                }
                else{ //GET THE PRODUCTS FOR EACH COLLECTION !  ****************************************************
                    
                    [self saveTimeUpdateIPhone];
                    
                    for (NSDictionary *dicCollection in arrayAddedOrModifiedCollections) { // download products only for new/updated collections
                        
                        NSLog(@"download products for new/updated collections");
                        NSString *collectionId = [NSString stringWithFormat:@"%@", [dicCollection objectForKey:@"id"]];
                        [self getProductsInCollectionWithCollectionId:collectionId andPageNumber:1];
                    }
                }
                
            });
            
        }else{
            NSLog(@"error occured : %@", [error description]);
            self.activityLoading.hidden = YES;
            self.labelLoading.text = @"Please, connect to the \n internet or try later";
        }
    }];
}

#pragma mark request products
-(void) getProductsInCollectionWithCollectionId : (NSString* )collection_id andPageNumber : (int) pageNumber{
    
    NSString *string_url =  [NSString stringWithFormat:@"%@/admin/products.json?published_status=published&collection_id=%@&page=%d&limit=250",website_string,collection_id, pageNumber];
    
    NSLog(@"complete url : %@", string_url);
    NSURL *url = [NSURL URLWithString:string_url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setValue:token forHTTPHeaderField:@"X-Shopify-Access-Token"];
    [request setURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if (!error){
            NSDictionary* dicFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            dispatch_sync(dispatch_get_global_queue(0, 0), ^{
                
                NSArray *arrayForProducts = [dicFromServer objectForKey:@"products"];
//            NSLog(@"collection : %@ products : %@", [[dicCollections objectForKey:collection_id] objectForKey:@"handle"], [arrayForProducts description]);
                
                if ([arrayForProducts count] != 0){  //check if the collection is empty
                    
                    //check if the collection exists in this dictionary and store it with the products
                    if ( [dicProductsCorrespondingToCollections objectForKey: collection_id] ) { // produts have already been stored for this collection
                        
                        if (pageNumber == 1) {//****added for bug//
                            [dicProductsCorrespondingToCollections removeObjectForKey:collection_id];
                            [dicProductsCorrespondingToCollections setObject:arrayForProducts forKey:collection_id];
                        }else{
                            
                            NSMutableArray *array = [[dicProductsCorrespondingToCollections objectForKey:collection_id] mutableCopy];
                            [array addObjectsFromArray:arrayForProducts];
                            [dicProductsCorrespondingToCollections setObject:array forKey:collection_id];
                            NSLog(@"not first time !");//****end//
                        }
                    }else{
                        NSLog(@"first time !");
                        [dicProductsCorrespondingToCollections setObject:arrayForProducts forKey:collection_id];
                    }
                }
                
                
                if ([arrayForProducts count] == 250){ //we still have products to download for this collection
                    [self getProductsInCollectionWithCollectionId:collection_id andPageNumber:(pageNumber + 1)];
                }else{//all the products have been downloaded
                    
                    count_collectionsToDownload--;
                    
                    if ([arrayForProducts count] == 0) {
                        [dicCollections removeObjectForKey:collection_id];
                        [dicProductsCorrespondingToCollections removeObjectForKey:collection_id];
                        NSLog(@"delete collection for id : %@", collection_id);
                        
                    }else{
                        
                        //replace the right collection updated !
                        sortedKeysForCategories = [[[dicProductsCorrespondingToCollections allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                            return [[[dicCollections objectForKey:a] objectForKey:@"title"] compare:[[dicCollections objectForKey:b] objectForKey:@"title"]];
                        }] mutableCopy];
                        
                        BOOL reloadData = ! self.collectionView.hidden;
                        
                        //check for a collection image
                        if ([[dicCollections objectForKey:collection_id] objectForKey:@"image"]) {
                            
                            NSDictionary *dicCollection = [dicCollections objectForKey:collection_id];
                            
                            [self getImageWithImageUrl:[[dicCollection objectForKey:@"image"] objectForKey:@"src"]
                                           andObjectId:collection_id
                                   lastImageToDownload:reloadData
                                    ImageForCollection:YES]; //modif
                        }else{
                            
                            //  download the first image of the first product
                            [self getImageWithImageUrl:[[[[dicProductsCorrespondingToCollections objectForKey:collection_id] firstObject] objectForKey:@"image"] objectForKey:@"src"]
                                           andObjectId:[[[dicProductsCorrespondingToCollections objectForKey:collection_id] firstObject] objectForKey:@"id"]
                                   lastImageToDownload:reloadData
                                    ImageForCollection:YES]; //modif
                        }
                        
                        NSLog(@"count for collections after dec: %d", count_collectionsToDownload);
                    }
                    
                    
                    
                    if (count_collectionsToDownload == 0) { //all collections have been downloaded -> save the date of download !
                        
                        
                        NSData *NewDataForProductsInCollections = [NSKeyedArchiver archivedDataWithRootObject:dicProductsCorrespondingToCollections];
                        
                        NSData *NewDataForCollections= [NSKeyedArchiver archivedDataWithRootObject:dicCollections];//save all the collections updated
                        
                        
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDirectory = [paths objectAtIndex:0];
                        NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:@"datasForProductsAndCollections"];
                        
                        if([NewDataForProductsInCollections writeToFile:imagePath atomically:NO]){
                            NSLog(@"datas well saved ! - products");
                        }else{
                            NSLog(@"error saving file - products ");
                        }
                        
                        NSString *imagePath_collection =[documentsDirectory stringByAppendingPathComponent:@"datasForDicCollections"];
                        
                        if([NewDataForCollections writeToFile:imagePath_collection atomically:NO]){
                            NSLog(@"datas well saved ! - collections");
                        }else{
                            NSLog(@"error saving file - collections ");
                        }
                        
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == NO) {
                            
                            [arrayProducts removeAllObjects];
                            [dicProductsCorrespondingToCollections enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                [arrayProducts addObjectsFromArray:obj];
                            }];
                            [self checkForProductsInSales];
                        }
                        
                        //GET ALL IMAGES TO DOWNLOAD
                        
                        //get all unique images ! avoid to download each image several times !
                        __block NSMutableArray *arrayIdsToBeDownloaded = [[NSMutableArray alloc] init];
                        __block NSMutableArray *arrayUrlsToBeDownloaded = [[NSMutableArray alloc] init];
                        [dicProductsCorrespondingToCollections enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
                            
                            for (NSDictionary *dicProduct in value) {
                                
                                if ( !  [arrayIdsToBeDownloaded containsObject:[dicProduct objectForKey:@"id"]]                         &&
                                    [ImageManagement getImageFromMemoryWithName:[dicProduct objectForKey:@"id"]] == nil                 &&
                                    !   [arrayIdsToBeDownloaded_checkForMissingImages containsObject:[dicProduct objectForKey:@"id"]]   &&
                                    [dicProduct objectForKey:@"id"] != nil                                                              &&
                                    [dicProduct objectForKey:@"image"] != nil ) //check if the images is not beign downloaded from "checkForMissingImages
                                {
                                    [arrayIdsToBeDownloaded addObject:[dicProduct objectForKey:@"id"]];
                                    [arrayUrlsToBeDownloaded addObject:[[dicProduct objectForKey:@"image"] objectForKey:@"src"]];
                                }
                            }
                        }];
                        
                        //DOWNLOAD IMAGES
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if ([arrayIdsToBeDownloaded count] > 0) {
                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
                            }
                            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == YES) {
                                
                                [self hideLoading];
                                [self.collectionView reloadData];
                                NSLog(@"test aaaaa");
                            }
                        });
                        
//                        BOOL refreshCollectionView = NO;
//                        if ([sortedKeysForCategories count] <= 3) {
//                            refreshCollectionView = YES;
//                        }
                        
                        
                        for (NSString *id_ImageToDownload in arrayIdsToBeDownloaded) {
                            
                            if ([ImageManagement getImageFromMemoryWithName:id_ImageToDownload] == nil) { //download image !

                                [self getImageWithImageUrl: [arrayUrlsToBeDownloaded objectAtIndex:[arrayIdsToBeDownloaded indexOfObject:id_ImageToDownload]]
                                               andObjectId: id_ImageToDownload
                                       lastImageToDownload: NO   // does not matter
                                        ImageForCollection: NO]; // modif
                            }
                            
                        }

                        
                        
                    }
                }
            });
        }
    }];
}

#pragma mark images

-(void) getImageWithImageUrl : (NSString*) imageUrl andObjectId:(NSString*) objectId lastImageToDownload: (BOOL) isLastImmage  ImageForCollection:(BOOL)isImageForCollection {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
        
        count_imagesToBeDownloaded++;
        NSLog(@"count for dwnld image : %d", count_imagesToBeDownloaded);
        
        NSURL *urlForImage = [NSURL URLWithString:[imageUrl getShopifyUrlforSize:@"large"]];
        
        NSMutableURLRequest *request_image = [NSMutableURLRequest requestWithURL:urlForImage];
        [NSURLConnection sendAsynchronousRequest:request_image
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (error) {
                                       NSLog(@"error in image dwnld: %@", [error description]);
                                       if (error.code == -1001 && [error.domain isEqualToString:@"NSURLErrorDomain"]) {
                                           [self getImageWithImageUrl:imageUrl andObjectId:objectId lastImageToDownload:NO ImageForCollection:isImageForCollection];
                                       }
                                   }
                                   
                                   count_imagesToBeDownloaded--;
                                   NSLog(@"count images to be downloaded after download : %d", count_imagesToBeDownloaded);
                                   
                                   if (count_imagesToBeDownloaded == 0) {

                                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
                                       
                                       if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == NO) {
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self.collectionView reloadData];
                                               [self hideLoading];
                                               NSLog(@"test image");
                                           });
                                       }
                                   }
                                   
                                   if ( ! error )
                                   {
                                       UIImage *image = [[UIImage alloc] initWithData:data];
                                       NSLog(@"image asynch : %@", [image description]);
                                       
                                       //save image in memory
                                       [ImageManagement saveImageWithData:data forName:objectId];
                                       
                                       //if the image is the first of a category : reloadData for collectionView
                                       
                                       if (isLastImmage == YES || isImageForCollection == YES ) { //Last ImageFromCollection is downloaded
                                           NSLog(@"end download !");
                                           dispatch_async(dispatch_get_main_queue(), ^{

                                               NSLog(@"reload data for collection");
                                               [self.collectionView reloadData];
                                           });
                                       }
                                   }
                                   
                               }];
    });
}


-(void) checkForMissingImages {
    
    //get all unique images ! avoid to download each image several times !
    arrayIdsToBeDownloaded_checkForMissingImages = [[NSMutableArray alloc] init];
    __block NSMutableArray *arrayUrlsToBeDownloaded = [[NSMutableArray alloc] init];
    __block NSMutableArray *arrayBoolImageForCollection = [[NSMutableArray alloc] init];
    
    [dicProductsCorrespondingToCollections enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        
        for (NSDictionary *dicProduct in value) {
            
            if ( !  [arrayIdsToBeDownloaded_checkForMissingImages containsObject:[dicProduct objectForKey:@"id"]] &&
                [ImageManagement getImageFromMemoryWithName:[dicProduct objectForKey:@"id"]] == nil &&
                [dicProduct objectForKey:@"id"] != nil &&
                [dicProduct objectForKey:@"image"] != nil ) {
                
                [arrayIdsToBeDownloaded_checkForMissingImages addObject:[dicProduct objectForKey:@"id"]];
                [arrayUrlsToBeDownloaded addObject:[[dicProduct objectForKey:@"image"] objectForKey:@"src"]];
                
                //check for collection's image
                if ([dicProduct isEqualToDictionary:[[dicProductsCorrespondingToCollections objectForKey:key] firstObject]]) {
                    [arrayBoolImageForCollection addObject:[NSNumber numberWithBool:YES]];
                }else{
                    [arrayBoolImageForCollection addObject:[NSNumber numberWithBool:NO]];
                }
            }
        }
    }];
    
    //        NSLog(@"to be downloaded recap : %@ and count to be downloaded : %lu" , [arrayUrlsToBeDownloaded description], [arrayUrlsToBeDownloaded count]);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([arrayIdsToBeDownloaded_checkForMissingImages count] > 0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
        }
    });
    
    for (NSString *id_ImageToDownload in arrayIdsToBeDownloaded_checkForMissingImages) {
        
        NSInteger index = [arrayIdsToBeDownloaded_checkForMissingImages indexOfObject:id_ImageToDownload];
        
        NSLog(@"bool for reload data : %@",[arrayBoolImageForCollection objectAtIndex:index] );
        
        [self getImageWithImageUrl:[arrayUrlsToBeDownloaded objectAtIndex:index]
                       andObjectId:id_ImageToDownload
               lastImageToDownload:[[arrayBoolImageForCollection objectAtIndex:index] boolValue]
                ImageForCollection:[[arrayBoolImageForCollection objectAtIndex:index] boolValue]];
    }
    
}

#pragma mark other

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    NSLog(@"prevent backup method called without error");
    return success;
}

-(void) showLoading{
    self.labelLoading.hidden = NO;
    self.activityLoading.hidden = NO;
    [self.activityLoading startAnimating];
    self.imageBackgroundForLoading.hidden = NO;
    self.viewForLabel.hidden = NO;
    self.collectionView.hidden = YES;
}

-(void) hideLoading{
    self.labelLoading.hidden = YES;
    self.activityLoading.hidden = YES;
    [self.activityLoading stopAnimating];
    self.imageBackgroundForLoading.hidden = YES;
    self.viewForLabel.hidden = YES;
    self.collectionView.hidden = NO;
}

-(void) saveTimeUpdateIPhone{
    //save the date of the update in the iphone
    
    NSDate *date = [NSDate date];
    NSDateFormatter *anotherDateFormatter = [[NSDateFormatter alloc] init];
    anotherDateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [anotherDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"];
    //        NSString *dateWithFormat = [anotherDateFormatter stringFromDate:date];
    
    //date in a dictionary
    NSDictionary *dicDateUpdate =[NSDictionary dictionaryWithObjectsAndKeys:[anotherDateFormatter stringFromDate:date], @"dateLastUpdateIPhone", nil];
    
    NSData *DataForDateUpdate= [NSKeyedArchiver archivedDataWithRootObject:dicDateUpdate];//save all the collections updated
    
    [[NSUserDefaults standardUserDefaults] setObject:DataForDateUpdate forKey:@"dateLastUpdateIPhone"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"date update - saved date : %@", [anotherDateFormatter stringFromDate:date]);
}

-(void) checkForProductsInSales{
   
    
    [arrayProducts enumerateObjectsUsingBlock:^(id dicProduct, NSUInteger idx, BOOL *stop) {
        
        [[dicProduct objectForKey:@"variants"] enumerateObjectsUsingBlock:^(id dicVariant, NSUInteger idx_variant, BOOL *stop) {
            
            if ( ! [[dicVariant objectForKey:@"compare_at_price"] isKindOfClass:[NSNull class]]) {
                
                [arrayIndexesActiclesOnSales addObject:[NSNumber numberWithUnsignedInteger:idx]];
                *stop=YES;
            }
        }];
        
    }];
     
}

#pragma mark IBActions

- (IBAction)goLeft:(id)sender {
    //access the parent view controller
    self.stlmMainViewController= (ScrollViewController *) self.parentViewController.parentViewController;
    [self.stlmMainViewController pageLeft];
}

- (IBAction)goToCart:(id)sender {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard_autolayout" bundle:nil];
    CartViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"CartViewController"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc1 animated:YES completion:nil];
    });
}

#pragma mark collection View delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard_autolayout" bundle:nil];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == NO) {
        
        ProductDetailsViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"ProductDetailsViewController"];
        vc1.dicProduct = [arrayProducts objectAtIndex:indexPath.row] ;
        vc1.product_id =[vc1.dicProduct objectForKey:@"id"];
        vc1.image = [ImageManagement getImageFromMemoryWithName:vc1.product_id];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc1 animated:YES];
        });
    }else{
        
        CategoryProductsViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"CategoryProductsViewController"];
        vc1.categoryName = [sortedKeysForCategories objectAtIndex:indexPath.row] ;
        vc1.collectionName = [[dicCollections objectForKey:vc1.categoryName] objectForKey:@"title"];
        vc1.arrayProducts = [dicProductsCorrespondingToCollections objectForKey:vc1.categoryName];
        [self.navigationController pushViewController:vc1 animated:YES];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == NO) {
        
        __block int count_products = 0;
        
        [dicProductsCorrespondingToCollections enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            count_products += [obj count];
        }];
        return count_products;
        
    }else{

        return [sortedKeysForCategories count];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Cell");
    
    CHTCollectionViewWaterfallCell *cell =
    (CHTCollectionViewWaterfallCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                                forIndexPath:indexPath];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"areCollectionsDisplayed"] == NO ) {
        
        @try {
            NSString * product_id = [[arrayProducts objectAtIndex:indexPath.row] objectForKey:@"id"];
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
        }else{
            
            cell.imageViewSale.image = nil;
        }
        
        return cell;
        
    }else{
        
        NSString *keyCategory;
        @try {
            keyCategory = [sortedKeysForCategories objectAtIndex:indexPath.row];
            cell.displayLabel.text = [[dicCollections objectForKey: [NSString stringWithFormat:@"%@", keyCategory]] objectForKey:@"title"];
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        if (cell.viewWhite.hidden) {
            cell.viewWhite.hidden = NO;
            cell.displayLabel.hidden = NO;
        }
        
        //check for specific collection image
        UIImage *collectionImage =[ImageManagement getImageFromMemoryWithName:keyCategory];
        if (collectionImage != nil) {
            
            cell.imageView.image = [ImageManagement getImageFromMemoryWithName:keyCategory];
        }else{ //take the fist product image available
            
            for (NSDictionary *dicProduct in [dicProductsCorrespondingToCollections objectForKey:keyCategory]) {
                
                NSString *productId = [dicProduct objectForKey:@"id"];
                
                if ([ImageManagement getImageFromMemoryWithName:productId] != nil) {
                    
                    cell.imageView.image = [ImageManagement getImageFromMemoryWithName:productId];
                    break;
                }
            }
        }
        return cell;
    }
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
    return CGSizeMake(50, 50);
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        
        layout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
        layout.headerHeight = 0;
        layout.footerHeight = 0;
        layout.minimumColumnSpacing = 2;
        layout.minimumInteritemSpacing = 2;
        if ([[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
            layout.columnCount = 3;
        }else{
            layout.columnCount = 2;
        }
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor colorWithRed:235.0f/255.0f
                                                          green:235.0f/255.0f
                                                           blue:235.0f/255.0f
                                                          alpha:1.0f];
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