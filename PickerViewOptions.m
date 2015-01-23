//
//  PickerViewOptions.m
//  208
//
//  Created by amaury soviche on 31/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "PickerViewOptions.h"

@implementation PickerViewOptions




@synthesize delegate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    //1. load xib file
    [[NSBundle mainBundle] loadNibNamed:@"PickerViewForOptions" owner:self options:nil];
    
    //2. adjust bounds
    self.bounds = self.ViewPickerOptions.bounds;
    
    //3. add as a subview
    [self addSubview:self.ViewPickerOptions];
    
    self.pickerForOptions.delegate = self;
    self.pickerNumber.delegate = self;
    
    return self;
}

-(void) initPickersWithDicProduct : (NSDictionary*) dicProduct{
    
    self.dicProduct = dicProduct;
    self.arrayOption1 = [NSMutableArray new];
    self.arrayTitleForVariant = [NSMutableArray new];
    self.arrayPositionVariantInArray = [NSMutableArray new];
    self.arrayInventoryQuantity = [NSMutableArray new];
    
    int positionInArray = 0;
    
    for (NSDictionary *dicVariant in [self.dicProduct objectForKey:@"variants"]) {
        
        NSString *options = @"";
        if ( ! [[dicVariant objectForKey:@"option1" ] isKindOfClass:[NSNull class]]) {
            options = [options stringByAppendingString:[dicVariant objectForKey:@"option1" ]];
        }
        if ( ! [[dicVariant objectForKey:@"option2" ] isKindOfClass:[NSNull class]]) {
            options = [[options stringByAppendingString:@", " ] stringByAppendingString:[dicVariant objectForKey:@"option2" ]];
        }
        if ( ! [[dicVariant objectForKey:@"option3" ] isKindOfClass:[NSNull class]]) {
            options = [[options stringByAppendingString:@", " ] stringByAppendingString:[dicVariant objectForKey:@"option3" ]];
        }
        
        if ([options isEqualToString:@"Default Title"] || [options isEqualToString:@"Default"]) {
            options = @"One size";
        }
        
        if(   (int)[[dicVariant objectForKey:@"inventory_quantity"] integerValue] <= 0 &&
           ! [[dicVariant objectForKey:@"inventory_management"] isKindOfClass:[NSNull class]]) { //if not available -> do not display it

            positionInArray++; //increment before continue !!!
            continue;
        }
        
        [self.arrayTitleForVariant addObject:options];
        [self.arrayPositionVariantInArray addObject:[NSNumber numberWithInt:positionInArray]];
        
        if ( ! [[dicVariant objectForKey:@"inventory_management"] isKindOfClass:[NSNull class]]) {
            [self.arrayInventoryQuantity addObject:[[dicVariant objectForKey:@"inventory_quantity"] stringValue]];
        }else{
            [self.arrayInventoryQuantity addObject:@"10"];
        }
        
        positionInArray++;
        
        NSLog(@"desc array title : %@", [self.arrayTitleForVariant description]);
        NSLog(@"desc array qte : %@", [self.arrayInventoryQuantity description]);
        NSLog(@"desc array position : %@", [self.arrayPositionVariantInArray description]);
    }
    
    positionInArray = 0;
    
    [self.pickerForOptions reloadAllComponents];
    [self.pickerNumber reloadAllComponents];
    
    if ([self.arrayTitleForVariant count] == 0) {
        NSLog(@"not available");
        [self.delegate isProductAvailable:NO];
        self.buttonSelect.enabled = NO;
    }else{
        NSLog(@"available");
        self.buttonSelect.enabled = YES;
        [self.delegate isProductAvailable:YES];
    }
}

#pragma mark pickerView dataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    if (pickerView == self.pickerForOptions) {
        return 1;
    }else{
        return 1;
    }
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (pickerView == self.pickerForOptions) {
        
        return [self.arrayTitleForVariant count];
        
    }else{
        
        if ([self.arrayTitleForVariant count] == 0) {
            return 0;
        }else{
            
            return (NSInteger)[[self.arrayInventoryQuantity objectAtIndex:[self.pickerForOptions selectedRowInComponent:0]] integerValue];
        }
        
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        tView.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
        tView.textColor = [UIColor colorWithRed:108.0/255.0f green:108/255.0f blue:108/255.0f alpha:1.0];
        tView.textAlignment = NSTextAlignmentCenter;
        tView.adjustsFontSizeToFitWidth = YES;
    }
    // Fill the label text here
    if (pickerView == self.pickerForOptions) {
        
        tView.text = [self.arrayTitleForVariant objectAtIndex:row];
        
    }
    else{
        tView.text =  [NSString stringWithFormat:@"%ld", row + 1];
        
    }
    
    return tView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{ //to be changed
    
    if (pickerView == self.pickerForOptions ) {
        
        [self.pickerNumber reloadAllComponents];
        [delegate didChooseVariantNumber:[self.pickerForOptions selectedRowInComponent:0]];
    }
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (thePickerView == self.pickerForOptions) {
        
        NSString *sizeText = [self.arrayTitleForVariant objectAtIndex:row];
        return sizeText;
    }
    else{
        return [NSString stringWithFormat:@"%ld", row + 1];
        
    }
}

- (IBAction)back:(UIButton *)sender {
    [delegate clickedCancel];
}

- (IBAction)select:(id)sender {//to be changed
    
    NSLog(@"array size : %@", [self.arrayOption1 description]);
    NSLog(@"dic product : %@", [self.dicProduct description]);
    
    NSString *number = [NSString stringWithFormat:@"%ld", [self.pickerNumber selectedRowInComponent:0] + 1];
    NSDictionary *dicVariant = [[self.dicProduct objectForKey:@"variants"]
                                objectAtIndex:[[self.arrayPositionVariantInArray objectAtIndex:[self.pickerForOptions selectedRowInComponent:0]] integerValue]];
    
    [self.delegate clickedSelectVariant:dicVariant andNumber:number];
}

@end
