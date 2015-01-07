//
//  PickerViewOptions.h
//  208
//
//  Created by amaury soviche on 31/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickerViewOptions;

@interface PickerViewOptions : UIView <UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, assign) id<PickerViewOptions> delegate;

@property (strong, nonatomic) IBOutlet UIView *ViewPickerOptions;

@property (strong, nonatomic) IBOutlet UIPickerView *pickerForOptions;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerNumber;

@property (strong, nonatomic) IBOutlet UIButton *buttonCancel;
@property (strong, nonatomic) IBOutlet UIButton *buttonSelect;

@property (strong,nonatomic) NSMutableArray *arrayOption1;

@property (strong, nonatomic) NSDictionary *dicProduct;

-(void) initPickersWithDicProduct : (NSDictionary*) dicProduct;

@property (strong,nonatomic) NSMutableArray *arrayTitleForVariant;
@property (strong,nonatomic) NSMutableArray *arrayPositionVariantInArray;
@property (strong,nonatomic) NSMutableArray *arrayInventoryQuantity;


@end

@protocol PickerViewOptions

-(void) clickedCancel;
-(void) clickedSelectVariant : (NSDictionary*)dicVariant andNumber : (NSString*) number;
-(void) didChooseVariantNumber : (NSInteger) VariantIndex;
-(void) isProductAvailable : (BOOL) isProductAvailable;

@end