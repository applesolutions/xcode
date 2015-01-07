//
//  CartViewController.m
//  208
//
//  Created by amaury soviche on 25/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "CartViewController.h"

#import "BuyWebViewViewController.h"
#import "ModifyProductInCartViewController.h"

#import "ImageManagement.h"
#import "NSString+Custom.h"

@interface CartViewController ()

@property (strong, nonatomic) IBOutlet UITableView *TableView;
@property (strong, nonatomic) IBOutlet UIButton *buttonAddCart;

@property (strong, nonatomic) IBOutlet UIView *ViewNavBar;
@end

@implementation CartViewController{
    NSMutableArray *arrayProductsInCart;
}

#pragma mark View LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.TableView.delegate = self;
    self.TableView.dataSource = self;
    self.TableView.allowsSelection = YES;
    
    CGRect frame = self.buttonAddCart.frame;
    frame.origin.y = self.view.frame.size.height - self.buttonAddCart.frame.size.height;
    self.buttonAddCart.frame = frame;
}

-(void) viewWillAppear:(BOOL)animated{
    
    self.ViewNavBar.backgroundColor =
    [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"red"] floatValue] / 255
                    green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"green"] floatValue] / 255
                     blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"blue"] floatValue] / 255
                    alpha:1];
    
    self.buttonAddCart.backgroundColor =
    [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorButtons"] objectForKey:@"red"] floatValue] / 255
                    green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorButtons"] objectForKey:@"green"] floatValue] / 255
                     blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorButtons"] objectForKey:@"blue"] floatValue] / 255
                    alpha:1];
    
    

    NSData *dataFromMemoryForCart = [[NSUserDefaults standardUserDefaults]objectForKey:@"arrayProductsInCart"];
    arrayProductsInCart = [[NSKeyedUnarchiver unarchiveObjectWithData:dataFromMemoryForCart] mutableCopy];
    
    self.buttonAddCart.enabled = NO;
    self.buttonAddCart.layer.opacity = 0.5f;
    if ([arrayProductsInCart count]>0) {
        self.buttonAddCart.enabled = YES;
        self.buttonAddCart.layer.opacity = 1.f;
    }
    
    [self.TableView reloadData];
}

#pragma mark IBActions

- (IBAction)back:(UIBarButtonItem*)sender {
    self.TableView.editing = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buyNow:(id)sender {
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard_autolayout" bundle:nil];
    BuyWebViewViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"BuyWebViewViewController"];
    vc1.arrayProductsInCart = arrayProductsInCart;
    
    [self presentViewController:vc1 animated:YES completion:nil];
}

#pragma mark tableView delegate + datasource

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard_autolayout" bundle:nil];
    ModifyProductInCartViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"ModifyProductInCartViewController"];
    vc1.indexOfObjectToModifyInCart = indexPath.row;
    vc1.dicProductToModifyInNSUserDefault = [[arrayProductsInCart objectAtIndex:indexPath.row] mutableCopy];
    [self presentViewController:vc1 animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [arrayProductsInCart removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        NSData *dataForCart = [NSKeyedArchiver archivedDataWithRootObject:arrayProductsInCart];
        [[NSUserDefaults standardUserDefaults] setObject:dataForCart forKey:@"arrayProductsInCart"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [tableView reloadData]; // tell table to refresh now
        
        if ([arrayProductsInCart count] == 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrayProductsInCart count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.25*self.view.frame.size.height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    NSString *itemIdForPicture = [[arrayProductsInCart objectAtIndex:indexPath.row] objectForKey:@"productId"];
    NSDictionary *DicItem = [[arrayProductsInCart objectAtIndex:indexPath.row] objectForKey:@"dicVariant"];
    NSString *qte = [[arrayProductsInCart objectAtIndex:indexPath.row] objectForKey:@"qte"];
//    NSString *title = [[[arrayProductsInCart objectAtIndex:indexPath.row] objectForKey:@"dicProduct"] objectForKey:@"title"];
    NSString *title = [[arrayProductsInCart objectAtIndex:indexPath.row] objectForKey:@"productTitle"];
    
    UILabel *LabelTitle = (UILabel*)[cell viewWithTag:100];
    UILabel *LabeSize = (UILabel*)[cell viewWithTag:101];
    UILabel *LabeQte = (UILabel*)[cell viewWithTag:102];
    UILabel *LabelPrice = (UILabel*)[cell viewWithTag:103];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:200];
    
    @try {
        
        imageView.image = [ImageManagement getImageFromMemoryWithName:itemIdForPicture];
        LabelTitle.text = title;
        LabeSize.text =[@"Details : " stringByAppendingString:[DicItem objectForKey:@"option1"]];
        LabeQte.text =[@"Quantity : " stringByAppendingString: qte ];
        
        if ([[DicItem objectForKey:@"option1"] isEqualToString:@"Default Title"] ||
            [[DicItem objectForKey:@"option1"] isEqualToString:@"Default"] ) {
            LabeSize.text = @"Details : one size";
        }
        
        if (! [[DicItem objectForKey:@"option2"] isKindOfClass:[NSNull class]]) {
            LabeSize.text = [[LabeSize.text stringByAppendingString:@", " ] stringByAppendingString:[DicItem objectForKey:@"option2" ]];
        }
        if (! [[DicItem objectForKey:@"option3"] isKindOfClass:[NSNull class]]) {
            LabeSize.text = [[LabeSize.text stringByAppendingString:@", " ] stringByAppendingString:[DicItem objectForKey:@"option3" ]];
        }
        
        float total_price_float = [[DicItem objectForKey:@"price"] floatValue] *[qte floatValue];
        NSString *total_price_string = [[NSString stringWithFormat:@"%f", total_price_float] stringAmountWithThousandsSeparator];
        
        
        if ([qte isEqualToString:@"1"]) {
            LabelPrice.text = [NSString stringWithFormat:@"%@ %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"currency"] ,  total_price_string];
        }else{
            
            LabelPrice.text =[[[[[[qte stringAmountWithThousandsSeparator] stringByAppendingString:@" x" ]
                                 stringByAppendingString:[NSString stringWithFormat:@" %@ ", [[NSUserDefaults standardUserDefaults] objectForKey:@"currency"] ] ]
                                stringByAppendingString:[[DicItem objectForKey:@"price"] stringAmountWithThousandsSeparator]]
                               stringByAppendingString:@" = " ]
                              stringByAppendingString: [NSString stringWithFormat:@"%@ %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"currency"], total_price_string] ];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
    }
    @finally {
        
    }
    
    return cell;
}


@end
