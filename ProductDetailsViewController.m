//
//  ProductDetailsViewController.m
//  208
//
//  Created by amaury soviche on 25/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "ProductDetailsViewController.h"

#import "CartViewController.h"
#import "AcceptedPayementView.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "NSString+HTML.h"
#import "GTMNSString+HTML.h"
#import "NSString+URL_Shopify.h"
#import "SocialMedias.h"
#import "NSString+Custom.h"

@interface ProductDetailsViewController ()
//@property (strong, nonatomic) IBOutlet UIImageView *ImageViewProduct;

@property (strong, nonatomic) UIImageView *ImageViewFirstProduct;

@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;

@property (strong, nonatomic) IBOutlet UIPageControl *pageIndicator;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonCart;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UITextView *textViewDescription;
@property (strong, nonatomic) IBOutlet UIButton *buttonAddToCart;
@property (strong, nonatomic) IBOutlet UILabel *LabelPrice;
@property (strong, nonatomic) IBOutlet UIButton *buttonTwitter;

@property (strong, nonatomic) UILabel *labelNewTitleForProduct;

@property (strong, nonatomic) NSMutableArray *arrayImages;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewMain;

@property (strong, nonatomic) IBOutlet UILabel *labelTitleProduct;

@property (strong, nonatomic) IBOutlet UIView *ViewNavBar;

//viewPrice for special prices :
@property (strong, nonatomic) IBOutlet UIView *ViewSpecialPrice;
@property (strong, nonatomic) IBOutlet UILabel *labelPriceBefore;
@property (strong, nonatomic) IBOutlet UILabel *labelPriceNow;
@property (strong, nonatomic) IBOutlet UIView *viewRed;

@property (strong, nonatomic) PickerViewOptions *picker;

//constraints

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *width;
@property (strong, nonatomic) IBOutlet UIView *viewReference;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraint_VerticalSpacing_PageControl_View;

@end

@implementation ProductDetailsViewController{
    
    UIScrollView *scrollViewWholePage;
    __block BOOL downloadFinished;
}

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#pragma mark view lifeCycle

-(void) viewWillAppear:(BOOL)animated{
    NSData *dataFromMemory = [[NSUserDefaults standardUserDefaults]objectForKey:@"arrayProductsInCart"];
    
    if([[NSKeyedUnarchiver unarchiveObjectWithData:dataFromMemory] count] == 0 ){
        self.buttonCart.image = [[UIImage imageNamed:@"nav-icon-cart"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }else{
        self.buttonCart.image = [[UIImage imageNamed:@"nav-icon-cart-full"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    //check for quantity
    self.buttonAddToCart.enabled = NO;
    self.buttonAddToCart.layer.opacity = 0.5f;
    [self.buttonAddToCart setTitle:@"Out of stock" forState:UIControlStateNormal];
    for (NSDictionary *dicVariant in [self.dicProduct objectForKey:@"variants"]) {
        
        if (([[dicVariant objectForKey:@"inventory_quantity"] integerValue] > 0 && //shopify handles the qte management
             [[dicVariant objectForKey:@"inventory_management"] isEqualToString:@"shopify"] )||
            
            [[dicVariant objectForKey:@"inventory_management"] isKindOfClass:[NSNull class]]) { //shopify does not handle the qte management
            
            self.buttonAddToCart.enabled = YES;
            self.buttonAddToCart.layer.opacity = 1.f;
            [self.buttonAddToCart setTitle:@"Buy now" forState:UIControlStateNormal];
        }
    }
    
    [self initPicker:self.dicProduct];
    
    self.ViewNavBar.backgroundColor =
    [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"red"] floatValue] / 255
                    green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"green"] floatValue] / 255
                     blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"blue"] floatValue] / 255
                    alpha:1];
    
    self.buttonAddToCart.backgroundColor =
    [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorButtons"] objectForKey:@"red"] floatValue] / 255
                    green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorButtons"] objectForKey:@"green"] floatValue] / 255
                     blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorButtons"] objectForKey:@"blue"] floatValue] / 255
                    alpha:1];
    
    self.pageIndicator.currentPageIndicatorTintColor =    [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"red"] floatValue] / 255
                                                                          green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"green"] floatValue] / 255
                                                                           blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"blue"] floatValue] / 255
                                                                          alpha:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapScreen:)];
    [self.scrollViewMain addGestureRecognizer:tap];
    
    //    NSLog(@"product : %@", [self.dicProduct description]);
    
    self.arrayImages = [[NSMutableArray alloc] init];
    
    self.ViewSpecialPrice.backgroundColor = [UIColor whiteColor];
    
    self.viewReference.backgroundColor = [UIColor clearColor];
    
    self.activity.hidden = YES;
    self.pageIndicator.numberOfPages = 1;
    
    [self definePriceForVariant:[[self.dicProduct objectForKey:@"variants"] firstObject]];
    
    if ( ! [[self.dicProduct objectForKey:@"body_html"] isKindOfClass:[NSNull class]]) {
        self.textViewDescription.text = [[self.dicProduct objectForKey:@"body_html"] stringByConvertingHTMLToPlainText];
    }else{
        self.textViewDescription.text = nil;
    }
    
    self.textViewDescription.editable=YES;
    self.textViewDescription.textAlignment = UITextAlignmentCenter;
    self.textViewDescription.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
    self.textViewDescription.editable = NO;
    
    self.labelTitleProduct.text = [self.dicProduct objectForKey:@"title"];
    [self.labelTitleProduct sizeToFit];
    
    //Scrollview for images
    self.scrollView.delegate=self;
    
    //IMAGE VIEW FOR FIRST IMAGE + CONSTRAINTS **************************************************************************************************
    
    //set height textViewDescription
    CGSize newSize = [self.textViewDescription sizeThatFits:CGSizeMake(self.view.frame.size.width - 40 , MAXFLOAT)];
    [self.textViewDescription addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[textView(%f)]",  newSize.height + 30]
                                             options:0 metrics:nil
                                               views:@{@"textView":self.textViewDescription}]];
    
    self.constraint_VerticalSpacing_PageControl_View.constant = 0.5 * self.view.frame.size.height;
    self.width.constant = self.view.frame.size.width;
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollViewMain.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.ImageViewFirstProduct = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width.constant, self.constraint_VerticalSpacing_PageControl_View.constant)];
    self.ImageViewFirstProduct.image = self.image;
    [self.scrollView addSubview:self.ImageViewFirstProduct];
    self.ImageViewFirstProduct.contentMode = UIViewContentModeScaleAspectFit;
    
    
    
    
    //download all images
    self.activity.hidden = YES;
    if ([[self.dicProduct objectForKey:@"images"] count] > 1) {
        self.pageIndicator.hidden = YES;
        [self.activity startAnimating];
        self.activity.hidden = NO;
    }
    
    NSMutableArray *arrayImagesVariants = [NSMutableArray new];
    for (NSDictionary *dicImage in [self.dicProduct objectForKey:@"images"]) {
        
        if ( ! [[dicImage objectForKey:@"src"] isEqualToString:[[self.dicProduct objectForKey:@"image"] objectForKey:@"src"]]) {
            [arrayImagesVariants addObject:[dicImage objectForKey:@"src"]];
        }
    }
    NSLog(@"images : %@", [arrayImagesVariants description]);
    
    [self getImagesForImageUrlArray:arrayImagesVariants];
}

- (void)viewDidLayoutSubviews {
    
    if (downloadFinished) {
        
        UIImageView* previousImageView = nil;
        
        for (UIImage *image in self.arrayImages) {
            
            NSLog(@"imageView first product : %@", NSStringFromCGRect(self.ImageViewFirstProduct.frame) );
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.ImageViewFirstProduct.frame];
            imageView.image = image;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.scrollView addSubview:imageView];
            
            //set top
            [self.scrollView addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lab]"
                                                     options:0 metrics:nil
                                                       views:@{@"lab":imageView}]];
            
            CGRect frame = imageView.frame;
            frame.origin.x = ( 1 + [self.arrayImages indexOfObject:image]) * self.viewReference.frame.size.width;
            imageView.frame = frame;
            
            previousImageView = imageView;
        }
        
        //last imageView : set right to define the contentSize.width of the scrollView
        if ([self.arrayImages count]) {
            
            [self.scrollView addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:@"H:[lab]-0-|"
                                                     options:0 metrics:nil
                                                       views:@{@"lab":previousImageView}]];
        }
        downloadFinished = NO;
    }
}

-(void) viewDidAppear:(BOOL)animated{
    
    //request !
//    NSString * token = [[NSUserDefaults standardUserDefaults]objectForKey:@"shopify_token"];
//    NSString * website_url = [[NSUserDefaults standardUserDefaults]objectForKey:@"website_url"];
//    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/admin/products/%@.json",website_url, self.product_id]];
//    NSLog(@"id to find : %@", self.product_id);
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setValue:token forHTTPHeaderField:@"X-Shopify-Access-Token"];
//    [request setURL:url];
//    
////    self.activity.hidden = YES;
////    if ([[self.dicProduct objectForKey:@"images"] count] > 1) {
////        self.pageIndicator.hidden = YES;
////        [self.activity startAnimating];
////        self.activity.hidden = NO;
////    }
////    
////    NSMutableArray *arrayImagesVariants = [NSMutableArray new];
////    for (NSDictionary *dicImage in [self.dicProduct objectForKey:@"images"]) {
////        
////        if ( ! [[dicImage objectForKey:@"src"] isEqualToString:[[self.dicProduct objectForKey:@"image"] objectForKey:@"src"]]) {
////            [arrayImagesVariants addObject:[dicImage objectForKey:@"src"]];
////        }
////    }
////    NSLog(@"images : %@", [arrayImagesVariants description]);
////    
////    [self getImagesForImageUrlArray:arrayImagesVariants];
//    
//    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
//        
//        if (!error){
//            NSDictionary* dicFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//            //            NSLog(@"dic for product : %@", [dicFromServer description]);
//            
//            NSMutableArray *arrayImagesVariants = [NSMutableArray new];
//            for (NSDictionary *dicImage in [self.dicProduct objectForKey:@"images"]) {
//                
//                if ( ! [[dicImage objectForKey:@"src"] isEqualToString:[[self.dicProduct objectForKey:@"image"] objectForKey:@"src"]]) {
//                    [arrayImagesVariants addObject:[dicImage objectForKey:@"src"]];
//                }
//            }
//            NSLog(@"images : %@", [arrayImagesVariants description]);
//            
//            [self getImagesForImageUrlArray:arrayImagesVariants];
//            
//            self.dicProduct = [dicFromServer objectForKey:@"product"];
//            [self definePriceForVariant:[[self.dicProduct objectForKey:@"variants"] firstObject]];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.picker initPickersWithDicProduct:self.dicProduct];
//            });
//            
//        }else{
//            NSLog(@"error : %@", [error description]);
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.activity stopAnimating];
//                self.activity.hidden = YES;
//                self.pageIndicator.hidden = NO;
//            });
//        }
//    }];
}

-(void) definePriceForVariant : (NSDictionary *) dicVariant{

    NSString * actualPrice = [[dicVariant objectForKey:@"price"] stringAmountWithThousandsSeparator];
    NSString *priceBefore = [dicVariant objectForKey:@"compare_at_price"];

    if ( ! [priceBefore isKindOfClass:[NSNull class]] && ! [priceBefore isEqualToString:@"0"] ) { //there is a discount
        self.ViewSpecialPrice.hidden = NO;
        self.LabelPrice.hidden = YES;
        
       
        priceBefore = [priceBefore stringAmountWithThousandsSeparator];
        
        self.labelPriceNow.text =[[NSString stringWithFormat:@"%@ ", [[NSUserDefaults standardUserDefaults] objectForKey:@"currency"]] stringByAppendingString: actualPrice];
        self.labelPriceBefore.text =[[NSString stringWithFormat:@"%@ ", [[NSUserDefaults standardUserDefaults] objectForKey:@"currency"]] stringByAppendingString: priceBefore];
        
        CGRect frame = self.viewRed.frame;
        //    frame.size.width = [self widthOfString:priceBefore withFont:[UIFont fontWithName:@"ProximaNova-Regular" size:17]] + 20;
        frame.size.width = [priceBefore getWidthWithFont:[UIFont fontWithName:@"ProximaNova-Regular" size:17]] + 20;
        
        self.viewRed.frame = frame;
        
        self.viewRed.center = self.labelPriceBefore.center;
        
    }else{
        self.ViewSpecialPrice.hidden = YES;
        self.LabelPrice.hidden = NO;
        self.LabelPrice.text = [[NSString stringWithFormat:@"%@ ", [[NSUserDefaults standardUserDefaults] objectForKey:@"currency"]] stringByAppendingString:actualPrice];
    }
}

-(void) initPicker : (NSDictionary *) dicProduct{
    
    self.picker = [[PickerViewOptions alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.picker initPickersWithDicProduct:self.dicProduct];
    
    self.picker.center = CGPointMake(self.view.center.x, self.view.frame.size.height + self.picker.frame.size.height/2);
    [self.view addSubview:self.picker];
    self.picker.delegate = self;
}

#pragma mark pickerView delegate

-(void) clickedSelectVariant:(NSDictionary *)dicVariant andNumber:(NSString *)number{
    
    NSDictionary *dicProduct = [NSDictionary dictionaryWithObjectsAndKeys:
                                [self.dicProduct objectForKey:@"id"], @"productId",
                                dicVariant, @"dicVariant",
                                self.dicProduct, @"dicProduct",
                                [self.dicProduct objectForKey:@"title"], @"productTitle",
                                number, @"qte", nil];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"arrayProductsInCart"] == nil){
        
        NSArray *arrayFirstProductForCart = [NSArray arrayWithObject:dicProduct];
        NSData *dataForCart = [NSKeyedArchiver archivedDataWithRootObject:arrayFirstProductForCart];
        [[NSUserDefaults standardUserDefaults] setObject:dataForCart forKey:@"arrayProductsInCart"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        
        NSData *dataFromMemoryForCart = [[NSUserDefaults standardUserDefaults]objectForKey:@"arrayProductsInCart"];
        NSMutableArray *arrayProductsInCart = [[NSKeyedUnarchiver unarchiveObjectWithData:dataFromMemoryForCart] mutableCopy];
        
        [arrayProductsInCart addObject:dicProduct];
        
        NSData *dataForCart = [NSKeyedArchiver archivedDataWithRootObject:arrayProductsInCart];
        
        [[NSUserDefaults standardUserDefaults] setObject:dataForCart forKey:@"arrayProductsInCart"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    NSLog(@"cart : %@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayProductsInCart"] description]);
    
    
    //ANIMATION ******************************************************************************
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        
        //add blur view
        
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        UIVisualEffectView *visualEffectView;
        
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
        visualEffectView.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);
        [self.view addSubview:visualEffectView];
        
        [UIView animateWithDuration:0.3 animations:^{
            visualEffectView.frame = self.view.frame;
        } completion:^(BOOL finished) {
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 95, 94)];
            imageView.center = self.view.center;
            imageView.image =[UIImage imageNamed:@"icon-check.png"];
            [visualEffectView addSubview:imageView];
            
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(back:) userInfo:nil repeats:NO];
        }];
        
    }else{
        
        AcceptedPayementView *ViewAddToCart = [[AcceptedPayementView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        [self.view addSubview:ViewAddToCart];
        
        [UIView animateWithDuration:0.3 animations:^{
            ViewAddToCart.frame = self.view.frame;
        } completion:^(BOOL finished) {
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 95, 94)];
            imageView.center = self.view.center;
            imageView.image =[UIImage imageNamed:@"icon-check.png"];
            [ViewAddToCart addSubview:imageView];
            //        [self.view bringSubviewToFront:imageView];
            
            
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(back:) userInfo:nil repeats:NO];
        }];
    }
}

-(void) clickedCancel{
    NSLog(@"cancel !");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self animationPickerViewHide];
    });
}

-(void)didChooseVariantNumber : (NSInteger) VariantIndex{
    [self definePriceForVariant:[[self.dicProduct objectForKey:@"variants"] objectAtIndex:VariantIndex]];
}

-(void) isProductAvailable:(BOOL)isProductAvailable{
    NSLog(@"aaa");
    self.buttonAddToCart.enabled = isProductAvailable;
    if (isProductAvailable) {
        self.buttonAddToCart.layer.opacity = 1.f;
    }else{
        self.buttonAddToCart.layer.opacity = 0.5f;
        NSLog(@"out of stock ! ");
        [self.buttonAddToCart setTitle:@"Out of stock" forState:UIControlStateNormal];
    }
}

#pragma mark animation PickerView

-(void) animationPickerViewShow{
    [UIView animateWithDuration:0.1 animations:^{
        self.picker.center = CGPointMake(self.view.center.x, self.view.frame.size.height - self.picker.frame.size.height/2);
        scrollViewWholePage.contentSize = CGSizeMake(self.view.frame.size.width , scrollViewWholePage.contentSize.height + self.picker.frame.size.height);
    } completion:^(BOOL finished) {
        
        
    }];
}

-(void) animationPickerViewHide{
    [UIView animateWithDuration:0.1 animations:^{
        self.picker.center = CGPointMake(self.view.center.x, self.view.frame.size.height + self.picker.frame.size.height/2);
        scrollViewWholePage.contentSize = CGSizeMake(self.view.frame.size.width , scrollViewWholePage.contentSize.height - self.picker.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark methods

-(void) getImagesForImageUrlArray : (NSArray *) arrayImageUrl {
    
    __block int countImageToDownload = (int)[arrayImageUrl count];
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        
        for (NSString *imageUrl in arrayImageUrl) {
            
            NSMutableURLRequest *request_image = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[imageUrl getShopifyUrlforSize:@"large"]]];
            [NSURLConnection sendAsynchronousRequest:request_image
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       
                                       if ( !error )
                                       {
                                           UIImage *image = [[UIImage alloc] initWithData:data];
                                           NSLog(@"image asynch : %@", [image description]);
                                           
                                           if ( ! [UIImagePNGRepresentation(self.image) isEqualToData:UIImagePNGRepresentation(image)]){
                                               if (image != nil) {
                                                   [self.arrayImages addObject:image];
                                               }
                                           }
                                       }
                                       
                                       countImageToDownload--;
                                       NSLog(@"count iumage to download : %d", countImageToDownload);
                                       
                                       if (countImageToDownload == 0) {
                                           
                                           downloadFinished = YES;
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               
                                               [self.activity stopAnimating];
                                               self.activity.hidden = YES;
                                               [self showImages : self.arrayImages];
                                           });
                                       }
                                   }];
        }
    });
}

-(void) showImages: (NSArray*) arrayImages {
    
    self.pageIndicator.hidden = NO;
    self.pageIndicator.numberOfPages = 1 + [arrayImages count];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * ( [arrayImages count] + 1 ) , self.scrollView.frame.size.height);
    
    [self viewDidLayoutSubviews];
}

#pragma mark UIGestures

- (void) didTapScreen: (UITapGestureRecognizer *) gesture {
    NSLog(@"touched");
    if (self.picker.frame.origin.y < self.view.frame.size.height) {
        [self animationPickerViewHide];
    }
}

#pragma mark ScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollViewDelegate{
    int page = scrollViewDelegate.contentOffset.x / scrollViewDelegate.frame.size.width;
    NSLog(@"page : %d", page);
    
    self.pageIndicator.currentPage = page;
}

#pragma mark IBAction

- (IBAction)addToBag:(id)sender {
    [self.view bringSubviewToFront:self.picker];
    [self animationPickerViewShow];
}

- (IBAction)shoppingCart:(id)sender {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard_autolayout" bundle:nil];
    CartViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"CartViewController"];
    [self presentViewController:vc1 animated:YES completion:nil];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tweet:(UIButton *)sender {
    
    [SocialMedias tweetWithMessage:[NSString stringWithFormat:@"Found this on @%@ ! What do you think about it ?", [[NSUserDefaults standardUserDefaults]objectForKey:@"twitterName"]]
                             image:self.image
                               url:nil
                    viewController:self];
}

@end
