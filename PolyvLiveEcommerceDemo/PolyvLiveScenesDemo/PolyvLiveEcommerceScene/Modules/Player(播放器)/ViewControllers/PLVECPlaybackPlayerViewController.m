//
//  PLVECPlayerViewController.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/23.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECPlaybackPlayerViewController.h"
#import <PolyvFoundationSDK/PLVProgressHUD.h>
#import "PLVECUtils.h"

@interface PLVECPlaybackPlayerViewController () <PLVPlaybackPlayerPresenterDelegate>

@property (nonatomic, strong) PLVPlaybackPlayerPresenter *presenter;

@property (nonatomic, strong) UIView *displayView;

@end

@implementation PLVECPlaybackPlayerViewController {
    BOOL _playbackProgressFlag;
}

#pragma mark - Setter

- (void)setDelegate:(id<PLVECPlaybackPlayerViewControlDelegate>)delegate {
    _delegate = delegate;
    _playbackProgressFlag = [delegate respondsToSelector:@selector(updateDowloadProgress:playedProgress:currentPlaybackTime:duration:)];
}

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.presenter = [[PLVPlaybackPlayerPresenter alloc] init];
        self.presenter.view = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self.presenter setupPlayerWithDisplayView:self.displayView];
}

- (void)setupUI {
    UIImageView *backgroundImg = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImg.image = [PLVECUtils imageForWatchResource:@"plv_background_img"];
    [self.view addSubview:backgroundImg];
    
    self.displayView = [[UIView alloc] init];
    self.displayView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.displayView];
    
    [self layoutViewsFrame];
}

- (void)layoutViewsFrame {
    CGFloat scale = 16.0 / 9.0;
    if (self.landscapeMode) {
        // 16:9 显示模式
        self.displayView.frame = CGRectMake(0, 130, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) / scale);
    } else {
        // 9:16 显示模式(刘海全屏裁剪)
        self.displayView.frame = CGRectMake(-(CGRectGetHeight(self.view.bounds) / scale - CGRectGetWidth(self.view.bounds)) / 2, 0, CGRectGetHeight(self.view.bounds) / scale, CGRectGetHeight(self.view.bounds));
        
        // 9:16 显示模式(刘海非全屏不裁剪)
        //self.playerSuperView.frame = self.view.bounds;
    }
}

#pragma mark - Public

- (void)play {
    [self.presenter play];
}

- (void)pause {
    [self.presenter pause];
}

- (void)seek:(NSTimeInterval)time {
    [self.presenter seek:time];
}

- (void)speedRate:(NSTimeInterval)speed {
    [self.presenter speedRate:speed];
}

- (void)destroy {
    [self.presenter destroy];
}

#pragma mark - <PLVPlaybackPlayerPresenterDelegate>

- (void)presenter:(PLVBasePlayerPresenter *)presenter loadMainPlayerFailure:(NSString *)message {
    PLVProgressHUD *hud = [PLVProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    hud.mode = PLVProgressHUDModeText;
    [hud.label setText:@"播放器加载失败"];
    hud.detailsLabel.text = message;
    [hud hideAnimated:YES afterDelay:2];
}

- (void)updateDowloadProgress:(CGFloat)dowloadProgress playedProgress:(CGFloat)playedProgress currentPlaybackTime:(NSString *)currentPlaybackTime duration:(NSString *)duration {
    if (_playbackProgressFlag) {
        [self.delegate updateDowloadProgress:dowloadProgress playedProgress:playedProgress currentPlaybackTime:currentPlaybackTime duration:duration];
    }
}

@end
