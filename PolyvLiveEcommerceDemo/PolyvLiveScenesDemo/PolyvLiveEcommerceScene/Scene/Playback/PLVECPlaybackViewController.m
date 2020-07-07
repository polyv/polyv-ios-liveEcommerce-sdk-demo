//
//  PLVECPlaybackViewController.m
//  PolyvLiveEcommerceDemo
//
//  Created by Lincal on 2020/4/30.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECPlaybackViewController.h"
#import <PolyvCloudClassSDK/PolyvCloudClassSDK.h>
#import "PLVLiveRoomPresenter.h"
#import "PLVECPlaybackPlayerViewController.h"
#import "PLVECPalybackHomePageView.h"
#import "PLVECUtils.h"

@interface PLVECPlaybackViewController () <PLVPalybackHomePageViewDelegate, PLVECPlaybackPlayerViewControlDelegate>

// UI视图
@property (nonatomic, strong) PLVECPalybackHomePageView *homePageView;
@property (nonatomic, strong) UIButton *closeButton;

// 业务模块
@property (nonatomic, strong) PLVLiveRoomPresenter *presenter; // 当前直播间业务类
@property (nonatomic, strong) PLVECPlaybackPlayerViewController *playerVC; // 播放器控制器

@end

@implementation PLVECPlaybackViewController

#pragma mark - Life Cycle

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

- (instancetype)initWithLiveRoomData:(PLVLiveRoomData *)roomData {
    self = [super init];
    if (self) {
        self.presenter = [[PLVLiveRoomPresenter alloc] init];
        self.presenter.roomData = roomData;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化页面UI
    [self setupUI];
    
    if (!self.presenter) {
        NSLog(@"%@ 初始化失败！请调用 -initWithChannel:roomData: API 初始化",NSStringFromClass(self.class));
        return;
    }
    
    // 初始化播放器控制器、绑定视图、设置代理
    self.playerVC = [[PLVECPlaybackPlayerViewController alloc] init];
    self.playerVC.roomData = self.presenter.roomData;
    self.playerVC.landscapeMode = self.landscapeMode;
    self.playerVC.delegate = self;
    
    self.playerVC.view.frame = self.view.bounds;
    [self.view insertSubview:self.playerVC.view atIndex:0];
    
    // 本类业务功能
    [self.presenter loadAndUpdateCurrentLiveRoomInfo];
    [self.presenter increaseCurrentLiveRoomExposure];
    
    [self observeRoomData];
}

- (void)setupUI {
    CGRect scrollViewFrame = CGRectMake(0, P_TopOfEdgeInsets(), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - P_TopOfEdgeInsets());
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollViewFrame) * 2, CGRectGetHeight(scrollViewFrame));
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = UIColor.clearColor;
    scrollView.bounces = NO;
    scrollView.alwaysBounceVertical = NO;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    self.homePageView = [[PLVECPalybackHomePageView alloc] init];
    self.homePageView.frame = CGRectMake(0, 0, CGRectGetWidth(scrollViewFrame), CGRectGetHeight(scrollViewFrame));
    self.homePageView.delegate = self;
    [scrollView addSubview:self.homePageView];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setImage:[PLVECUtils imageForWatchResource:@"plv_close_btn"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat closeBtn_y = 32.0;
    if (@available(iOS 11.0, *)) {
        closeBtn_y = self.view.safeAreaLayoutGuide.layoutFrame.origin.y+12.0;
    }
    self.closeButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds)-47, closeBtn_y, 32, 32);
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - View control

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - KVO

- (void)observeRoomData {
    PLVLiveRoomData *roomData = self.presenter.roomData;
    [roomData addObserver:self forKeyPath:KEYPATH_LIVEROOM_CHANNEL options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [roomData addObserver:self forKeyPath:KEYPATH_LIVEROOM_VIEWCOUNT options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [roomData addObserver:self forKeyPath:KEYPATH_LIVEROOM_DURATION options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [roomData addObserver:self forKeyPath:KEYPATH_LIVEROOM_PLAYING options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserveRoomData {
    PLVLiveRoomData *roomData = self.presenter.roomData;
    [roomData removeObserver:self forKeyPath:KEYPATH_LIVEROOM_CHANNEL];
    [roomData removeObserver:self forKeyPath:KEYPATH_LIVEROOM_VIEWCOUNT];
    [roomData removeObserver:self forKeyPath:KEYPATH_LIVEROOM_DURATION];
    [roomData removeObserver:self forKeyPath:KEYPATH_LIVEROOM_PLAYING];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isKindOfClass:PLVLiveRoomData.class]) {
        PLVLiveRoomData *roomData = object;
        if ([keyPath isEqualToString:KEYPATH_LIVEROOM_CHANNEL]) {
            if (!roomData.channelInfo)
                return;
            [self.homePageView updateChannelInfo:roomData.channelInfo.publisher coverImage:roomData.channelInfo.coverImage];
        } else if ([keyPath isEqualToString:KEYPATH_LIVEROOM_VIEWCOUNT]) {
            [self.homePageView updateWatchViewCount:roomData.watchViewCount];
        } else if ([keyPath isEqualToString:KEYPATH_LIVEROOM_DURATION]) {
            [self.homePageView updateVideoDuration:roomData.duration];
        } else if ([keyPath isEqualToString:KEYPATH_LIVEROOM_PLAYING]) {
            [self.homePageView updatePlayButtonState:roomData.playing];
        }
    }
}

#pragma mark - Action

- (void)closeButtonAction:(UIButton *)button {
    [self destroy];
    [self.playerVC destroy];
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Private

- (void)destroy {
    [self removeObserveRoomData];
}

#pragma mark - <PLVPalybackHomePageViewDelegate>

- (void)homePageView:(PLVECPalybackHomePageView *)homePageView switchPause:(BOOL)pause {
    if (pause) {
        [self.playerVC pause];
    } else {
        [self.playerVC play];
    }
}

- (void)homePageView:(PLVECPalybackHomePageView *)homePageView seekToTime:(NSTimeInterval)time {
    [self.playerVC seek:time];
}

- (void)homePageView:(PLVECPalybackHomePageView *)homePageView switchSpeed:(CGFloat)speed {
    [self.playerVC speedRate:speed];
}

#pragma mark - <PLVECPlaybackPlayerViewControlDelegate>

- (void)updateDowloadProgress:(CGFloat)dowloadProgress playedProgress:(CGFloat)playedProgress currentPlaybackTime:(NSString *)currentPlaybackTime duration:(NSString *)duration {
    [self.homePageView updateDowloadProgress:dowloadProgress playedProgress:playedProgress currentPlaybackTime:currentPlaybackTime duration:duration];
}

@end
