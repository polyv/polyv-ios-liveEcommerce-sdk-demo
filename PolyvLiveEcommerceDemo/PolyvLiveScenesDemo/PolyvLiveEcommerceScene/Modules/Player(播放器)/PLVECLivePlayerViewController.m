//
//  PLVECLivePlayerViewController.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/23.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECLivePlayerViewController.h"
#import <PolyvFoundationSDK/PLVProgressHUD.h>
#import <PolyvCloudClassSDK/PLVLivePlayerController.h>
#import "PLVECAudioAnimalView.h"
#import "PLVECUtils.h"

@interface PLVECLivePlayerViewController () <PLVPlayerControllerDelegate, PLVLivePlayerControllerDelegate>

@property (nonatomic, strong) UIView *backgroundView; // 显示播放背景图
@property (nonatomic, strong) UIImageView *noLiveImgView;
@property (nonatomic, strong) UILabel *noLiveLabel;

@property (nonatomic, strong) UIView *displayView; // 显示视频区域

@property (nonatomic, strong) PLVECAudioAnimalView *audioAnimalView; // 显示音频模式

@property (nonatomic, strong) PLVLivePlayerController *player; // 直播播放器

@property (nonatomic, assign) BOOL reOpening; // 是否正在加载channelJSON

@property (nonatomic, assign) BOOL warmUpPlaying; // 是否在暖场播放

@end

@implementation PLVECLivePlayerViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    self.player = [[PLVLivePlayerController alloc] initWithChannelId:self.roomData.channelId
                                                              userId:self.roomData.userIdForAccount
                                                              playAD:NO
                                                         displayView:self.displayView
                                                            delegate:self];
    self.player.cameraClosed = NO;
}

- (void)setupUI {
    UIImageView *backgroundImg = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImg.image = [PLVECUtils imageForWatchResource:@"plv_background_img"];
    [self.view addSubview:backgroundImg];
    
    self.displayView = [[UIView alloc] init];
    self.displayView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.displayView];
    
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.hidden = YES;
    [self.view addSubview:self.backgroundView];
    
    UIImage *noLiveImage = [PLVECUtils imageForWatchResource:@"plv_skin_player_background"];
    self.noLiveImgView = [[UIImageView alloc] initWithImage:noLiveImage];
    [self.backgroundView addSubview:self.noLiveImgView];
    
    self.noLiveLabel = [[UILabel alloc] init];
    self.noLiveLabel.text = @"暂无直播";
    self.noLiveLabel.textColor = UIColor.whiteColor;
    self.noLiveLabel.textAlignment = NSTextAlignmentCenter;
    self.noLiveLabel.font = [UIFont systemFontOfSize:14.0];
    [self.backgroundView addSubview:self.noLiveLabel];
    
    [self layoutViewsFrame];
}

- (void)layoutViewsFrame {
    CGFloat scale = 16.0 / 9.0;
    self.backgroundView.frame = CGRectMake(0, 130, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) / scale);
    self.noLiveImgView.frame = CGRectMake(CGRectGetWidth(self.backgroundView.bounds)/2-77, CGRectGetHeight(self.backgroundView.bounds)/2-60, 154, 120);
    self.noLiveLabel.frame = CGRectMake(CGRectGetWidth(self.backgroundView.bounds)/2-100, CGRectGetMaxY(self.noLiveImgView.frame)+12, 200, 14);
    
    if (self.landscapeMode) {
        // 16:9 显示模式
        self.displayView.frame = self.backgroundView.frame;
    } else {
        // 9:16 显示模式(刘海全屏裁剪)
        self.displayView.frame = CGRectMake(-(CGRectGetHeight(self.view.bounds) / scale - CGRectGetWidth(self.view.bounds)) / 2, 0, CGRectGetHeight(self.view.bounds) / scale, CGRectGetHeight(self.view.bounds));
        
        // 9:16 显示模式(刘海非全屏不裁剪)
        //self.playerSuperView.frame = self.view.bounds;
    }
}

#pragma mark - Public

- (void)playLive {
    [self reloadLive];
}

- (void)pauseLive {
    [self.player pause];
}

- (void)reloadLive {
    [self reOpenPlayerWithLineIndex:-1 codeRate:nil showHud:YES];
}

- (void)switchPlayLine:(NSUInteger)Line {
    [self reOpenPlayerWithLineIndex:Line codeRate:self.roomData.curCodeRate showHud:NO];
}

- (void)switchPlayCodeRate:(NSString *)codeRate {
    [self reOpenPlayerWithLineIndex:self.roomData.curLine codeRate:codeRate showHud:NO];
}

- (void)switchAudioMode:(BOOL)audioMode {
    [self showAudioAnimalView:audioMode];
    [self.player switchAudioMode:audioMode];
}

- (void)destroy {
    [self.player clearPlayersAndTimers];
}

#pragma mark - Priveta

- (void)showAudioAnimalView:(BOOL)show {
    if (!self.audioAnimalView) {
        self.audioAnimalView = [[PLVECAudioAnimalView alloc] init];
        self.audioAnimalView.frame = self.displayView.bounds;
        self.audioAnimalView.contentLable.text = @"音频直播中";
        [self.displayView addSubview:self.audioAnimalView];
    }
    [self.audioAnimalView setHidden:!show];
}

/// 播放或刷新直播 / 切换线路 / 切换其他清晰度
- (void)reOpenPlayerWithLineIndex:(NSInteger)lineIndex codeRate:(NSString *)codeRate showHud:(BOOL)showHud {
    if (!self.reOpening && !((PLVLivePlayerController *)self.player).linkMic) {
        self.reOpening = YES;
        PLVProgressHUD *hud = nil;
        if (showHud) {
            hud = [PLVProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
            [hud.label setText:@"加载直播..."];
        }
        
        __weak typeof(self) weakSelf = self;
        [(PLVLivePlayerController *)self.player loadChannelWithLineIndex:lineIndex codeRate:codeRate completion:^{
            weakSelf.reOpening = NO;
            if (hud != nil) {
                [hud hideAnimated:YES];
            }
        } failure:^(NSString *message) {
            weakSelf.reOpening = NO;
            if (hud != nil) {
                hud.label.text = [NSString stringWithFormat:@"加载直播失败:%@", message];
                [hud hideAnimated:YES];
            }
        }];
    }
}

#pragma mark - <PLVPlayerControllerDelegate>

/// 刷新皮肤的多码率和多线路的按钮
- (void)playerController:(PLVPlayerController *)playerController codeRateItems:(NSMutableArray *)codeRateItems codeRate:(NSString *)codeRate lines:(NSUInteger)lines line:(NSInteger)line {
    NSLog(@"player: codeRateItems %@ codeRate %@ lines %ld line %ld",codeRateItems,codeRate,lines,line);
    self.roomData.curLine = line;
    self.roomData.lines = lines;
    self.roomData.curCodeRate = codeRate;
    self.roomData.codeRateItems = codeRateItems;
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
    self.warmUpPlaying = YES;
    self.backgroundView.hidden = YES;
    
//    PLVIJKFFMoviePlayerController *subPlayer = [playerController valueForKey:@"subPlayer"];
//    if ([subPlayer isKindOfClass:PLVIJKFFMoviePlayerController.class]) {
//        CGSize natureSize = subPlayer.naturalSize;
//        NSLog(@"natureSize %@",NSStringFromCGSize(natureSize));
//    }
}

/// 广告播放器已结束播放暖场广告
- (void)playerController:(PLVPlayerController *)playerController subPlayerDidFinish:(NSNotification *)notification {
    self.warmUpPlaying = NO;
}

/// 主播放器已准备好开始播放正片
- (void)playerController:(PLVPlayerController *)playerController mainPlaybackIsPreparedToPlay:(NSNotification *)notification {
    self.warmUpPlaying = NO;
//    if ([playerController conformsToProtocol:@protocol(PLVPlayerControllerPrivateProtocol)]) {
//        PLVPlayerController<PLVPlayerControllerPrivateProtocol> *playerVC = (id<PLVPlayerControllerPrivateProtocol>)playerController;
//        CGSize natureSize = playerVC.mainPlayer.naturalSize;
//        NSLog(@"natureSize %@",NSStringFromCGSize(natureSize));
//    }
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

#pragma mark - <PLVLivePlayerControllerDelegate>

/// 定时器查询(每6秒)的直播流状态回调
- (void)livePlayerController:(PLVLivePlayerController *)livePlayer streamState:(PLVLiveStreamState)streamState {
    self.roomData.liveState = streamState;
    self.backgroundView.hidden = YES;
    if (!self.warmUpPlaying && streamState == PLVLiveStreamStateNoStream) {
        self.backgroundView.hidden = NO;
    }
}

/// 重连播放器回调
- (void)reconnectPlayer:(PLVLivePlayerController *)livePlayer {
    // 直播开始时，将触发此回调，通过reopenLive刷新直播
    [self reloadLive];
}

/// 频道信息更新
- (void)liveVideoChannelDidUpdate:(PLVLiveVideoChannel *)channel {
    self.roomData.sessionId = channel.sessionId;
}

/// 直播播放器的播放状态改变
- (void)livePlayerController:(PLVLivePlayerController *)livePlayer playing:(BOOL)playing {
    self.roomData.playing = playing;
}

@end
