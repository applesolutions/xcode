//
//  ScrollViewController.h
//  QRCodeReader
//
//  Created by amaury soviche on 18/05/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollViewController : UIViewController<UIScrollViewDelegate>


@property (weak) IBOutlet UIScrollView *scrollView;


-(void) pageLeft;

-(void) pageRight;

-(void) enableScrollView;

-(void) disableScrollView;

@end
