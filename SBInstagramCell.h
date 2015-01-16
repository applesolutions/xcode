//
//  SBInstagramCell.h
//  instagram
//
//  Created by Santiago Bustamante on 8/31/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBInstagramMediaEntity.h"
#import <AVFoundation/AVFoundation.h>

#define SB_IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@interface SBInstagramCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *userLabel;
@property (strong, nonatomic) UIImageView *userImage;
@property (strong, nonatomic) UILabel *captionLabel;
@property (strong, nonatomic) UIButton *imageButton;
@property (assign, nonatomic) SBInstagramMediaPagingEntity *entity;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL showOnePicturePerRow;
@property (nonatomic, strong) UIImageView *videoPlayImage;

@property (strong, nonatomic) UILabel *labelLikes;
@property (nonatomic, strong) UIImageView *imageViewLikes;


@property (nonatomic, copy) void (^videoControlBlock)(BOOL tap, NSString *videoUrl);

-(void)setEntity:(SBInstagramMediaPagingEntity *)entity indexPath:(NSIndexPath *)index playerContent:(id)playerItems;

@end
