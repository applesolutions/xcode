//
//  SBInstagramCell.m
//  instagram
//
//  Created by Santiago Bustamante on 8/31/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import "SBInstagramCell.h"
#import "SBInstagramImageViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation SBInstagramCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
    }
    return self;
}


-(void)setEntity:(SBInstagramMediaPagingEntity *)entity indexPath:(NSIndexPath *)index playerContent:(id )avPlayerIn{
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 6;
    [self setupCell];
    
    [self.imageButton setBackgroundImage:[UIImage imageNamed:[SBInstagramModel model].loadingImageName] forState:UIControlStateNormal];
    _entity = entity;
    
    SBInstagramImageEntity *imgEntity = entity.mediaEntity.images[@"thumbnail"];
    if (imgEntity.width <= CGRectGetWidth(self.imageButton.frame)) {
        imgEntity = entity.mediaEntity.images[@"low_resolution"];
    }
    
    if (imgEntity.width <= CGRectGetWidth(self.imageButton.frame)) {
        imgEntity = entity.mediaEntity.images[@"standard_resolution"];
    }
    
    [imgEntity downloadImageWithBlock:^(UIImage *image, NSError *error) {
        if (self.indexPath.row == index.row) {
            [self.imageButton setBackgroundImage:image forState:UIControlStateNormal];
        }
    }];
    
    self.imageButton.userInteractionEnabled = !self.showOnePicturePerRow;
    //    self.imageButton.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
    
    
    if (self.showOnePicturePerRow) {
        
        self.labelLikes.text = [NSString stringWithFormat:@"%ld",self.entity.mediaEntity.likes];
        //        NSLog(@"define likes : %ld", self.entity.mediaEntity.likes);
        [self.contentView addSubview:self.labelLikes];
        
        self.userLabel.text = self.entity.mediaEntity.userName;
        [self.contentView addSubview:self.userLabel];
        
        
        self.captionLabel.text = self.entity.mediaEntity.caption;
        
        
        NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
        if (SB_IS_IPAD) {
            style.minimumLineHeight = 24.f;
            style.maximumLineHeight = 24.f;
        }else{
            style.minimumLineHeight = 18.f;
            style.maximumLineHeight = 18.f;
        }
        NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style};
        _captionLabel.attributedText = [[NSAttributedString alloc] initWithString:_captionLabel.text
                                                                       attributes:attributtes];
        
        [self.contentView addSubview:self.captionLabel];
        CGSize newSize = [_captionLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame) - 10 , MAXFLOAT)];
        //        NSLog(@"view width : %f", CGRectGetWidth(self.frame) - 10);
        //        NSLog(@"txt to display : %@", _captionLabel.text);
        //        NSLog(@"new size : %@", NSStringFromCGSize(newSize));
        if (newSize.height) {
            CGRect frame = _captionLabel.frame;
            frame.size.height = newSize.height;
            _captionLabel.frame = frame;
        }
        
        
        [self.userImage setImage:[UIImage imageNamed:[SBInstagramModel model].loadingImageName]];
        [self.contentView addSubview:self.userImage];
        
        [self.contentView addSubview:self.imageViewLikes];
        
        [SBInstagramModel downloadImageWithUrl:self.entity.mediaEntity.profilePicture andBlock:^(UIImage *image2, NSError *error) {
            if (image2 && !error && self.indexPath.row == index.row) {
                [self.userImage setImage:image2];
            }
        }];
        
        self.videoPlayImage.frame = CGRectMake(CGRectGetMaxX(self.imageButton.frame) - 34, CGRectGetMinY(self.imageButton.frame) + 4, 30, 30);
        
    }else{
        [self.userLabel removeFromSuperview];
        [self.userImage removeFromSuperview];
        [self.captionLabel removeFromSuperview];
        
        self.videoPlayImage.frame = CGRectMake(CGRectGetMaxX(self.imageButton.frame) - 22, CGRectGetMinY(self.imageButton.frame) + 2, 20, 20);
        
    }
    
    self.videoPlayImage.hidden = YES;
    if (entity.mediaEntity.type == SBInstagramMediaTypeVideo) {
        self.videoPlayImage.hidden = NO;
        if (self.showOnePicturePerRow) {
            self.imageButton.userInteractionEnabled = YES;
        }
    }
}

-(void) selectedImage:(id)selector{
    
    if (self.entity.mediaEntity.type == SBInstagramMediaTypeVideo && self.showOnePicturePerRow) {
        
        NSString *url = ((SBInstagramVideoEntity *) _entity.mediaEntity.videos[@"low_resolution"]).url;
        if ([SBInstagramModel model].playStandardResolution) {
            url = ((SBInstagramVideoEntity *) _entity.mediaEntity.videos[@"standard_resolution"]).url;
        }
        if (self.videoControlBlock) {
            self.videoControlBlock(YES,url);
        }
        //
        //        if (self.avPlayer.rate == 0) {
        //            if (CMTimeCompare(self.avPlayer.currentItem.currentTime, self.avPlayer.currentItem.duration) == 0) {
        //                [self.avPlayer seekToTime:kCMTimeZero];
        //            }
        //            [self.avPlayer play];
        //            [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPauseImageName]];
        //
        //            if (!_loadComplete) {
        //                _timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(loadingVideo) userInfo:nil repeats:YES];
        //            }
        //
        //
        //        }else{
        //            [self.avPlayer pause];
        //            [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
        //        }
        
        return;
    }
    
    UIViewController *viewCon = (UIViewController *)self.nextResponder;
    
    while (![viewCon isKindOfClass:[UINavigationController class]]) {
        viewCon = (UIViewController *)viewCon.nextResponder;
    }
    
    SBInstagramImageViewController *img = [SBInstagramImageViewController imageViewerWithEntity:self.entity.mediaEntity];
    
    [((UINavigationController *)viewCon) pushViewController:img animated:YES];
    
}

- (void) setupCell{
    
    if (!_imageButton) {
        _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    [_imageButton setFrame:CGRectMake(20, 60, self.frame.size.width-40, self.frame.size.width)];
    [_imageButton addTarget:self action:@selector(selectedImage:) forControlEvents:UIControlEventTouchUpInside];
    [_imageButton setBackgroundImage:[UIImage imageNamed:[SBInstagramModel model].loadingImageName] forState:UIControlStateNormal];
    self.imageButton.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_imageButton];
    
    if (!_userLabel) {
        _userLabel = [[UILabel alloc] init];
    }
    _userLabel.frame = CGRectMake(60, 20, CGRectGetWidth(self.frame) - 45, 35);
    _userLabel.textColor = [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorViewTitleCollection"] objectForKey:@"red"] floatValue] / 255
                                           green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorViewTitleCollection"] objectForKey:@"green"] floatValue] / 255
                                            blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorViewTitleCollection"] objectForKey:@"blue"] floatValue] / 255
                                           alpha:1];
    if (SB_IS_IPAD) {
        [_userLabel setFont:[UIFont fontWithName:@"ProximaNova-Semibold" size:22]];
    }else{
        [_userLabel setFont:[UIFont fontWithName:@"ProximaNova-Semibold" size:18]];
    }
    
    if (!_labelLikes) {
        _labelLikes = [[UILabel alloc] init];
    }
    _labelLikes.frame = CGRectMake(45, CGRectGetMaxY(self.imageButton.frame) + 5 , 200, 20);
    _labelLikes.textColor = [UIColor blackColor];
    if (SB_IS_IPAD) {
        [_labelLikes setFont:[UIFont fontWithName:@"ProximaNova-SemiBold" size:22]];
        
    }else{
        [_labelLikes setFont:[UIFont fontWithName:@"ProximaNova-SemiBold" size:14]];
    }
    
    if (!_imageViewLikes) {
        _imageViewLikes = [[UIImageView alloc] init];
    }
    _imageViewLikes.frame = CGRectMake(20, CGRectGetMaxY(self.imageButton.frame) + 5 , 20, 20);
    _imageViewLikes.image = [UIImage imageNamed:@"icon-heart"];
    _imageViewLikes.contentMode = UIViewContentModeScaleAspectFit;
    
    if (!_captionLabel) {
        _captionLabel = [[UILabel alloc] init];
    }
    _captionLabel.frame = CGRectMake(20, CGRectGetMaxY(_labelLikes.frame) + 10 , CGRectGetWidth(self.frame) - 40, 75);
    _captionLabel.numberOfLines = 0;
    _captionLabel.textColor = [UIColor blackColor];
    
    if (SB_IS_IPAD) {
        _captionLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:20];
    }else{
        _captionLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:14];
    }
    
    _captionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    if (!_userImage) {
        _userImage = [[UIImageView alloc] init];
    }
    _userImage.frame = CGRectMake(20, 20, 35, 35);
    _userImage.contentMode = UIViewContentModeScaleAspectFit;
    _userImage.layer.masksToBounds = YES;
    _userImage.layer.cornerRadius = 17.5;
    
    
    if (!_videoPlayImage) {
        _videoPlayImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    [_videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
    [self.contentView addSubview:_videoPlayImage];
}


@end