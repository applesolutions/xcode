//
//  ModifyProductInCartViewController.h
//  208
//
//  Created by amaury soviche on 01/11/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerViewOptions.h"

@interface ModifyProductInCartViewController : UIViewController < UIScrollViewDelegate, PickerViewOptions>


@property NSInteger indexOfObjectToModifyInCart;
@property (strong,nonatomic) NSMutableDictionary *dicProductToModifyInNSUserDefault;


@end
