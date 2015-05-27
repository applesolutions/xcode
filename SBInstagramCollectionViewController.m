//
//  SBInstagramCollectionViewController.m
//  instagram
//
//  Created by Santiago Bustamante on 8/31/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import "SBInstagramCollectionViewController.h"
#import "SBInstagramController.h"
#import "SBInstagramMediaEntity.h"
#import "SBInstagramModel.h"

#import "IKLoginViewController.h"
#import "MediaWebViewController.h"

#import "ScrollViewController.h"

@interface SBInstagramCollectionViewController()
{
    NSString *currentVideoURL_;
    BOOL isVideoPlaying_;
    
}
@property (nonatomic, strong) NSMutableArray *mediaArray;
@property (nonatomic, strong) SBInstagramController *instagramController;
@property (nonatomic, assign) BOOL downloading;
@property (nonatomic, assign) BOOL hideFooter;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSArray *multipleLastEntities;


@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) UIView *avPlayerView;
@property (nonatomic, strong) NSTimer *timerVideo;
@property (nonatomic, assign) BOOL loadCompleteVideo;
@property (nonatomic, strong) UIImageView *videoPlayImage;

@property (nonatomic, strong) ScrollViewController *stlmMainViewController;


@end

@implementation SBInstagramCollectionViewController

+(NSString *)appVersion{
    return @"2.1.0";
}

-(NSString *)version{
    return [SBInstagramCollectionViewController appVersion];
}

- (id) initWithCollectionViewLayout:(UICollectionViewLayout *)layout{
    if ((self = [super initWithCollectionViewLayout:layout])) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicator startAnimating];
    }
    return self;
}

-(void)goRight{
    NSLog(@"right ");
    //access the parent view controller
    self.stlmMainViewController= (ScrollViewController *) self.parentViewController.parentViewController;
    [self.stlmMainViewController pageRight];
}

-(void)goLeft{
    NSLog(@"left ");
    //access the parent view controller
    self.stlmMainViewController= (ScrollViewController *) self.parentViewController.parentViewController;
    [self.stlmMainViewController pageLeft];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Instagram";
    
    //set right button
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav-icon-right"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(goRight)];
    item.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItem:item animated:YES];
    
    //set right button
    UIBarButtonItem *itemSettings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav-icon-settings"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(goLeft)];
    itemSettings.tintColor = [UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:itemSettings animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateColors)
                                                 name:@"updatePhoneSettings"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadNext)
                                                 name:@"updateInstagramFeed"
                                               object:nil];
    
    
    self.downloading = YES;
    self.mediaArray = [NSMutableArray arrayWithCapacity:0];
    [self.collectionView registerClass:[SBInstagramCell class] forCellWithReuseIdentifier:@"SBInstagramCell"];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.multipleLastEntities = [NSArray array];
    
    self.instagramController = [SBInstagramController instagramControllerWithMainViewController:self];
    self.instagramController.isSearchByTag = self.isSearchByTag;
    self.instagramController.searchTag = self.searchTag;
 
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"instagramId"] != nil &&
        [[[NSUserDefaults standardUserDefaults] objectForKey:@"instagramId"] count] == 1) {
        
        [self downloadNext];
    }else{
        
    }
    
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"] objectForKey:@"red"] floatValue] / 255
                                                          green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"] objectForKey:@"green"] floatValue] / 255
                                                           blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"] objectForKey:@"blue"] floatValue] / 255
                                                          alpha:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"] objectForKey:@"alpha"] floatValue]];
    
    refreshControl_ = [[SBInstagramRefreshControl alloc] initInScrollView:self.collectionView];
    [refreshControl_ addTarget:self action:@selector(refreshCollection:) forControlEvents:UIControlEventValueChanged];
    
    loaded_ = YES;
    
        [self showSwitch];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
}

-(void)updateColors{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"red"] floatValue] / 255
                                                                                green:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"green"] floatValue] / 255
                                                                                 blue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"blue"] floatValue] / 255
                                                                                 alpha:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"colorNavBar"] objectForKey:@"alpha"] floatValue]]];
        
    });
    
}



-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
    
}

-(void) segmentChanged:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    if (self.showOnePicturePerRow != segmentedControl.selectedSegmentIndex) {
        self.showOnePicturePerRow = segmentedControl.selectedSegmentIndex;
    }
}

- (void) refreshCollection{
    NSLog(@"insta id : %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"instagramId"]);
    [self refreshCollection:nil];
}

- (void) refreshCollection:(id) sender{
    [self.mediaArray removeAllObjects];
    [self downloadNext];
    if (self.activityIndicator.isAnimating)
        [self.activityIndicator stopAnimating];
}

- (void) downloadNext{
    __weak typeof(self) weakSelf = self;
    self.downloading = YES;
    if (!self.activityIndicator.isAnimating)
        [self.activityIndicator startAnimating];
    if ([self.mediaArray count] == 0) {
        
        //multiple users id
        if ([SBInstagramModel model].instagramMultipleUsersId) {
            [self.instagramController mediaMultipleUserWithArr:[SBInstagramModel model].instagramMultipleUsersId complete:^(NSArray *mediaArray,NSArray *lastMedias, NSError *error) {
                if ([refreshControl_ isRefreshing]) {
                    [refreshControl_ endRefreshing];
                }
                if (mediaArray.count == 0 && error) {
                    
                    NSLog(@"downld next insta id : %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"instagramId"]);
                    NSLog(@"error: %@", error.userInfo);
                    
//                    SB_showAlert(@"Instagram", @"No results found", @"OK");
                    [weakSelf.activityIndicator stopAnimating];
                }else{
                    [weakSelf.mediaArray addObjectsFromArray:mediaArray];
                    [weakSelf.collectionView reloadData];
                    weakSelf.multipleLastEntities = lastMedias;
                }
                weakSelf.downloading = NO;
            }];
        }
        //only one user configured
        else{
            NSString *uId = [SBInstagramModel model].instagramUserId ?: INSTAGRAM_USER_ID;
            if (SBInstagramModel.isSearchByTag && [SBInstagramModel searchTag].length > 0) {
                uId = [SBInstagramModel searchTag];
            }
            
            [self.instagramController mediaUserWithUserId:uId andBlock:^(NSArray *mediaArray, NSError *error) {
                if ([refreshControl_ isRefreshing]) {
                    [refreshControl_ endRefreshing];
                }
                if (error || mediaArray.count == 0) {
//                    SB_showAlert(@"Instagram", @"No results found", @"OK");
                    [weakSelf.activityIndicator stopAnimating];
                }else{
                    [weakSelf.mediaArray addObjectsFromArray:mediaArray];
                    [weakSelf.collectionView reloadData];
                }
                weakSelf.downloading = NO;
                
            }];
        }
    }
    //download nexts
    else{
        
        //multiple users id
        if ([SBInstagramModel model].instagramMultipleUsersId) {
            
            [self.instagramController mediaMultiplePagingWithArr:self.multipleLastEntities complete:^(NSArray *mediaArray, NSArray *lastMedia, NSError *error) {
                
                weakSelf.multipleLastEntities = lastMedia;
                
                NSUInteger a = [self.mediaArray count];
                [weakSelf.mediaArray addObjectsFromArray:mediaArray];
                
                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
                [mediaArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSUInteger b = a+idx;
                    NSIndexPath *path = [NSIndexPath indexPathForItem:b inSection:0];
                    [arr addObject:path];
                }];
                
                [weakSelf.collectionView performBatchUpdates:^{
                    [weakSelf.collectionView insertItemsAtIndexPaths:arr];
                } completion:nil];
                
                weakSelf.downloading = NO;
                
                if (mediaArray.count == 0) {
                    [weakSelf.activityIndicator stopAnimating];
                    weakSelf.activityIndicator.hidden = YES;
                    weakSelf.hideFooter = YES;
                    [weakSelf.collectionView reloadData];
                }
            }];
            
        }else{
            
            [self.instagramController mediaUserWithPagingEntity:[self.mediaArray objectAtIndex:(self.mediaArray.count-1)] andBlock:^(NSArray *mediaArray, NSError *error) {
                
                NSUInteger a = [self.mediaArray count];
                [weakSelf.mediaArray addObjectsFromArray:mediaArray];
                
                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
                [mediaArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSUInteger b = a+idx;
                    NSIndexPath *path = [NSIndexPath indexPathForItem:b inSection:0];
                    [arr addObject:path];
                }];
                
                [weakSelf.collectionView performBatchUpdates:^{
                    [weakSelf.collectionView insertItemsAtIndexPaths:arr];
                } completion:nil];
                
                weakSelf.downloading = NO;
                
                if (mediaArray.count == 0) {
                    [weakSelf.activityIndicator stopAnimating];
                    weakSelf.activityIndicator.hidden = YES;
                    weakSelf.hideFooter = YES;
                    [weakSelf.collectionView reloadData];
                }
                
            }];
        }
    }
    
}


- (void) setShowOnePicturePerRow:(BOOL)showOnePicturePerRow{
    BOOL reload = NO;
    if (_showOnePicturePerRow != showOnePicturePerRow) {
        reload = YES;
    }
    _showOnePicturePerRow = showOnePicturePerRow;
    if (reload && loaded_) {
        [self.avPlayer pause];
        [[self.avPlayer currentItem] removeObserver:self forKeyPath:@"status"];
        [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
        [self.avPlayerView removeFromSuperview];
        isVideoPlaying_ = NO;
        [self.collectionView reloadData];
    }
    
}

- (void) setShowSwitchModeView:(BOOL)showSwitchModeView{
    _showSwitchModeView = showSwitchModeView;
    if (loaded_) {
        [self showSwitch];
    }
    
}

- (void) showSwitch{
    if (self.showSwitchModeView) {
        segmentedControl_ = [[UISegmentedControl alloc] initWithItems:@[[UIImage imageNamed:@"sb-grid-selected.png"],[UIImage imageNamed:@"sb-table-selected.png"]]];
        [self.view addSubview:segmentedControl_];
        
        segmentedControl_.segmentedControlStyle = UISegmentedControlStylePlain;
        CGRect frame = segmentedControl_.frame;
        frame.origin.y = 5;
        frame.size.width  = 200;
        frame.origin.x = self.view.center.x - 100;
        segmentedControl_.frame = frame;
        segmentedControl_.selectedSegmentIndex = _showOnePicturePerRow;
        [segmentedControl_ addTarget:self
                              action:@selector(segmentChanged:)
                    forControlEvents:UIControlEventValueChanged];
        
        frame = self.collectionView.frame;
        frame.origin.y = CGRectGetMaxY(segmentedControl_.frame) + 5;
        frame.size.height = CGRectGetHeight([[UIScreen mainScreen] applicationFrame]) - CGRectGetMinY(frame);
        self.collectionView.frame = frame;
        
    }else{
        if (segmentedControl_) {
            [segmentedControl_ removeFromSuperview];
            segmentedControl_ = nil;
        }
        
        CGRect frame = self.collectionView.frame;
        frame.origin.y = 0;
        frame.size.height = CGRectGetHeight([[UIScreen mainScreen] applicationFrame]);
        self.collectionView.frame = frame;
    }
}


- (void) videoConfig{
    
    if (!currentVideoURL_) {
        return;
    }
    
    AVAsset* avAsset = [AVAsset assetWithURL:[NSURL URLWithString:currentVideoURL_]];
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
    
    if (!self.avPlayer) {
        self.avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
        [avPlayerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    }else{
        [[self.avPlayer currentItem] removeObserver:self forKeyPath:@"status"];
        [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
        [self.avPlayer replaceCurrentItemWithPlayerItem:avPlayerItem];
        [avPlayerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    }
    
    if (!self.avPlayerLayer) {
        self.avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        self.avPlayerView = [[UIView alloc] initWithFrame:CGRectZero];
        //        self.avPlayerView.backgroundColor = [UIColor clearColor];
        [self.avPlayerView.layer addSublayer:self.avPlayerLayer];
        [self.collectionView addSubview:self.avPlayerView];
        
        //        [self.avPlayerLayer setFrame:CGRectMake(0, 0, 320, 320)];
        //        [self.avPlayerView setFrame:CGRectMake(0, 0, 320, 320)];
        [self.avPlayerLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width-80, self.view.frame.size.width-80)];
        [self.avPlayerView setFrame:CGRectMake(0, 0, self.view.frame.size.width-80, self.view.frame.size.width-80)];
        //        [self.avPlayerLayer setFrame:CGRectMake(20, 60, self.view.frame.size.width-80, self.view.frame.size.width)];
        //        [self.avPlayerView setFrame:CGRectMake(20, 60, self.view.frame.size.width-80, self.view.frame.size.width)];
        
        //        (20, 60, self.frame.size.width-40, self.frame.size.width)
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVideo:)];
        [self.avPlayerView addGestureRecognizer:singleFingerTap];
        
        if (!_videoPlayImage) {
            _videoPlayImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        }
        [_videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
        [self.avPlayerView addSubview:_videoPlayImage];
        
    }
    
    [self.avPlayerView removeFromSuperview];
    [self.collectionView addSubview:self.avPlayerView];
    
    
    
    [self.avPlayer seekToTime:kCMTimeZero];
    [self.avPlayer play];
    isVideoPlaying_ = YES;
    [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
    
    self.loadCompleteVideo = NO;
}

- (void)tapVideo:(UITapGestureRecognizer *)recognizer {
    
    if (self.avPlayer.rate == 0) {
        if (CMTimeCompare(self.avPlayer.currentItem.currentTime, self.avPlayer.currentItem.duration) == 0) {
            [self.avPlayer seekToTime:kCMTimeZero];
        }
        [self.avPlayer play];
        [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPauseImageName]];
        
        if (!_loadCompleteVideo) {
            _timerVideo = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(loadingVideo) userInfo:nil repeats:YES];
        }
        
        
    }else{
        [self.avPlayer pause];
        [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
    }
    
    
}

- (void) loadingVideo{
    self.videoPlayImage.hidden = !self.videoPlayImage.hidden;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    if ([self.avPlayer currentItem] == [notification object]) {
        [self.avPlayer seekToTime:kCMTimeZero];
        [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPlayImageName]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[AVPlayerItem class]])
    {
        AVPlayerItem *item = (AVPlayerItem *)object;
        //playerItem status value changed?
        if ([keyPath isEqualToString:@"status"])
        {   //yes->check it...
            switch(item.status)
            {
                case AVPlayerItemStatusFailed:
                    if (_timerVideo) {
                        [_timerVideo invalidate];
                    }
                    break;
                case AVPlayerItemStatusReadyToPlay:
                    if (_timerVideo) {
                        [_timerVideo invalidate];
                    }
                    self.loadCompleteVideo = YES;
                    self.videoPlayImage.hidden = NO;
                    [self.videoPlayImage setImage:[UIImage imageNamed:[SBInstagramModel model].videoPauseImageName]];
                    break;
                case AVPlayerItemStatusUnknown:
                    break;
            }
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.mediaArray count];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SBInstagramMediaPagingEntity *entity = [self.mediaArray objectAtIndex:indexPath.row];
    NSLog(@"entity url: %@", entity.mediaEntity.Url);
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard_autolayout" bundle:nil];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isUserLoggedIn"] == NO) {
        
        IKLoginViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"IKLoginViewController"];
        vc1.urlForMedia = entity.mediaEntity.Url;
        vc1.instagramCollectionViewController = self;
        [self presentViewController:vc1 animated:YES completion:nil];
        //        [self.navigationController pushViewController:vc1 animated:YES];
        
    }else{
        
        [self presentMediaWebViewControllerWithUrl:entity.mediaEntity.Url];
    }
}


-(void) presentMediaWebViewControllerWithUrl:(NSURL*)urlForMedia{
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard_autolayout" bundle:nil];
    MediaWebViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"MediaWebViewController"];
    vc1.urlForMedia = urlForMedia;
    [self presentViewController:vc1 animated:YES completion:nil];
    //        [self.navigationController pushViewController:vc1 animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SBInstagramCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SBInstagramCell" forIndexPath:indexPath];
    
    if ([self.mediaArray count]>0) {
        SBInstagramMediaPagingEntity *entity = [self.mediaArray objectAtIndex:indexPath.row];
        cell.indexPath = indexPath;
        cell.showOnePicturePerRow = self.showOnePicturePerRow;
        
        __weak SBInstagramCell* weakCell = cell;
        
        [cell setVideoControlBlock:^(BOOL tap, NSString *videoUrl) {
            
            if (tap) {
                currentVideoURL_ = videoUrl;
                [self videoConfig];
                
                weakCell.videoPlayImage.hidden = YES;
                
                CGPoint point = [weakCell convertPoint:weakCell.imageButton.frame.origin toView:self.collectionView];
                
                CGRect frame = weakCell.imageButton.frame;
                frame.origin = point;
                self.avPlayerView.frame = frame;
                
                self.videoPlayImage.frame = CGRectMake(CGRectGetMaxX(weakCell.imageButton.frame) - 50, 4, 30, 30); // -34
                
                if (_timerVideo) {
                    [_timerVideo invalidate];
                }
                _timerVideo = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(loadingVideo) userInfo:nil repeats:YES];
            }
            
            
            
        }];
        
        if (entity.mediaEntity.type != SBInstagramMediaTypeVideo || !self.showOnePicturePerRow) {
            currentVideoURL_ = nil;
        }
        
        [cell setEntity:entity indexPath:indexPath playerContent:self.avPlayer];
        //        NSLog(@"collectionViewController  !");
        
    }
    
    if (indexPath.row == [self.mediaArray count]-1 && !self.downloading) {
        [self downloadNext];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell1 forItemAtIndexPath:(NSIndexPath *)indexPath

{
    if ([collectionView.indexPathsForVisibleItems indexOfObject:indexPath] == NSNotFound)
    {
        //        SBInstagramCell *cell = (SBInstagramCell *)cell1;
        
        if (isVideoPlaying_) {
            [self.avPlayer pause];
            [[self.avPlayer currentItem] removeObserver:self forKeyPath:@"status"];
            [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
            [self.avPlayerView removeFromSuperview];
            isVideoPlaying_ = NO;
        }
        
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (self.hideFooter) {
        return CGSizeZero;
    }
    return CGSizeMake(CGRectGetWidth(self.view.frame),40);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    
    CGSize size = CGSizeMake(self.view.frame.size.width, 20);
    return size;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (kind == UICollectionElementKindSectionHeader ){
        
        NSLog(@"define header");
        
        UICollectionReusableView *foot = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        
        
        return foot;
        
    }else if(  kind == UICollectionElementKindSectionFooter){
        
        UICollectionReusableView *foot = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
        
        CGPoint center = self.activityIndicator.center;
        center.x = foot.center.x;
        center.y = 20;
        self.activityIndicator.center = center;
        
        [foot addSubview:self.activityIndicator];
        
        return foot;
        
    }else return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.showOnePicturePerRow) {
        
        SBInstagramMediaPagingEntity *paging = [self.mediaArray objectAtIndex:indexPath.row];
        //        NSLog(@"index path : %@", indexPath);
        
        //        NSLog(@"media array label caption : %@", paging.mediaEntity.caption);
        UILabel *gettingSizeLabel = [[UILabel alloc] init];
        if (SB_IS_IPAD) {
            gettingSizeLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:20];
        }else{
            gettingSizeLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:14];
        }
        gettingSizeLabel.text = paging.mediaEntity.caption;
        
        NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
        if (SB_IS_IPAD) {
            style.minimumLineHeight = 24.f;
            style.maximumLineHeight = 24.f;
        }else{
            style.minimumLineHeight = 18.f;
            style.maximumLineHeight = 18.f;
        }
        NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style};
        gettingSizeLabel.attributedText = [[NSAttributedString alloc] initWithString:gettingSizeLabel.text
                                                                          attributes:attributtes];
        
        gettingSizeLabel.numberOfLines = 0;
        gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width, 9999);
        
        CGSize newSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
        //get the good height for the text with the good font
        
        
        CGFloat newHeight = 35 + (self.view.frame.size.width - 10) + 25 + ( 10 + newSize.height); //75
        
        if (SB_IS_IPAD) {
            if (newSize.height == 0) {
                //                NSLog(@"too bad !");
                return CGSizeMake(680, newHeight);
            }else{
                //                NSLog(@"all good ");
                return CGSizeMake(680, newHeight);
            }
        }else{
            //            if (newSize.height == 0) {
            //                NSLog(@"too bad !");
            //                return CGSizeMake(340, 500);
            //            }else{
            ////                NSLog(@"all good ");
            //                return CGSizeMake(340, newHeight);
            //            }
            if (newSize.height == 0) {
                //                NSLog(@"too bad !");
                return CGSizeMake([UIScreen mainScreen].bounds.size.width - 40 , 500);
            }else{
//                NSLog(@"all good ");
                return CGSizeMake([UIScreen mainScreen].bounds.size.width - 40 , newHeight);
            }
        }
        
        //set the new height for the cell
        
        
        //        SBInstagramCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SBInstagramCell" forIndexPath:indexPath];
        //        NSLog(@"text to display : %@", cell.captionLabel.text);
        
        
        //        if (CGRectGetMaxY(cell.captionLabel.frame) == 0) {
        //            return CGSizeMake(320, 500);
        //        }else{
        //            return CGSizeMake(320, CGRectGetMaxY(cell.captionLabel.frame));
        //        }
    }else{
        if (SB_IS_IPAD) {
            return CGSizeMake(200, 200);
        }
        return CGSizeMake(100, 100);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (self.showOnePicturePerRow) {
        return 10;
    }
    return 10* (SB_IS_IPAD?2:1);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (self.showOnePicturePerRow) {
        return 10;
    }
    return 10 * (SB_IS_IPAD?2:1);
}


@end
