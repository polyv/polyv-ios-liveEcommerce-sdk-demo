//
//  PLVECPlayerViewController.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/23.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECPlaybackPlayerViewController.h"
#import <PolyvFoundationSDK/PLVProgressHUD.h>
#import <PolyvCloudClassSDK/PLVVodPlayerController.h>
#import "PLVECUtils.h"

@interface PLVECPlaybackPlayerViewController () <PLVPlayerControllerDelegate, PLVVodPlayerControllerDelegate>

@property (nonatomic, strong) PLVVodPlayerController *player;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    self.player = [[PLVVodPlayerController alloc] initWithVodId:self.roomData.vid
                                                    displayView:self.displayView
                                                       delegate:self];
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
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)seek:(NSTimeInterval)time {
    [self.player seek:time];
}

- (void)speedRate:(NSTimeInterval)speed {
    [self.player speedRate:speed];
}

- (void)destroy {
    [self.player clearPlayersAndTimers];
}

#pragma mark - <PLVPlayerControllerDelegate>

/// 刷新皮肤的多码率和多线路的按钮
- (void)playerController:(PLVPlayerController *)playerController codeRateItems:(NSMutableArray *)codeRateItems codeRate:(NSString *)codeRate lines:(NSUInteger)lines line:(NSInteger)line {
}

/// 加载主播放器失败（原因：1.网络请求失败；2.如果是直播，且该频道设置了限制条件）
- (void)playerController:(PLVPlayerController *)playerController loadMainPlayerFailure:(NSString *)message {
    PLVProgressHUD *hud = [PLVProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    hud.mode = PLVProgressHUDModeText;
    [hud.label setText:@"播放器加载失败"];
    hud.detailsLabel.text = message;
    [hud hideAnimated:YES afterDelay:2];
}

/// 播放器状态改变的Message消息回调
- (void)playerController:(PLVPlayerController *)playerController showMessage:(NSString *)message {
    
}

/// 改变视频所在窗口（主屏或副屏）的底色
- (void)changePlayerScreenBackgroundColor:(PLVPlayerController *)playerController {
    
}

/// 广告播放器已准备好开始播放暖场广告
- (void)playerController:(PLVPlayerController *)playerController subPlaybackIsPreparedToPlay:(NSNotification *)notification {

}

/// 广告播放器已结束播放暖场广告
- (void)playerController:(PLVPlayerController *)playerController subPlayerDidFinish:(NSNotification *)notification {
    
}

/// 主播放器已准备好开始播放正片
- (void)playerController:(PLVPlayerController *)playerController mainPlaybackIsPreparedToPlay:(NSNotification *)notification {
    
}

/// 主播放器加载状态有改变
- (void)playerController:(PLVPlayerController *)playerController mainPlayerLoadStateDidChange:(NSNotification *)notification {
    
}

/// 主播放器播放播放状态有改变
- (void)playerController:(PLVPlayerController *)playerController mainPlayerPlaybackStateDidChange:(NSNotification *)notification {
    
}

/// 主播放器已结束播放
- (void)playerController:(PLVPlayerController *)playerController mainPlayerPlaybackDidFinish:(NSNotification *)notification {
    
}

/// 主播放器Seek完成
- (void)playerController:(PLVPlayerController *)playerController mainPlayerDidSeekComplete:(NSNotification *)notification {
    
}

/// 主播放器精准Seek完成
- (void)playerController:(PLVPlayerController *)playerController mainPlayerAccurateSeekComplete:(NSNotification *)notification {
    
}

#pragma mark - <PLVVodPlayerControllerDelegate>

/// 点播播放器的播放状态改变，刷新皮肤的总播放时间
- (void)vodPlayerController:(PLVVodPlayerController *)vodPlayer duration:(NSTimeInterval)duration playing:(BOOL)playing {
    self.roomData.duration = duration;
    self.roomData.playing = playing;
}

/// 点播播放器的播放状态改变，刷新皮肤的总播放时间，已加载进度，和已播放进度
- (void)vodPlayerController:(PLVVodPlayerController *)vodPlayer dowloadProgress:(CGFloat)dowloadProgress playedProgress:(CGFloat)playedProgress currentPlaybackTime:(NSString *)currentPlaybackTime duration:(NSString *)duration {
    if (_playbackProgressFlag) {
        [self.delegate updateDowloadProgress:dowloadProgress playedProgress:playedProgress currentPlaybackTime:currentPlaybackTime duration:duration];
    }
}

@end
