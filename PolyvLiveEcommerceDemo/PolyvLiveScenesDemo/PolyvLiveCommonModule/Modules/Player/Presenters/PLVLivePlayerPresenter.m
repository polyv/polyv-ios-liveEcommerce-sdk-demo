//
//  PLVLivePlayerPresenter.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/9.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVLivePlayerPresenter.h"
#import <PolyvCloudClassSDK/PolyvCloudClassSDK.h>

@interface PLVLivePlayerPresenter () <PLVPlayerControllerDelegate, PLVLivePlayerControllerDelegate>

@property (nonatomic, strong) PLVLivePlayerViewModel *viewModel;

@property (nonatomic, strong) PLVLivePlayerController *player;

@end

@implementation PLVLivePlayerPresenter

#pragma mark - Override

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [[PLVLivePlayerViewModel alloc] init];
    }
    return self;
}

- (void)setupPlayerWithDisplayView:(UIView *)displayView {
    if (self.player) {
        return;
    }
    
    self.player = [[PLVLivePlayerController alloc] initWithChannelId:self.roomData.channelId
                                                              userId:self.roomData.userIdForAccount
                                                              playAD:NO
                                                         displayView:displayView
                                                            delegate:self];
    self.player.cameraClosed = NO;
    self.viewModel.player = self.player;
}

- (void)setPlayerFrame:(CGRect)rect {
    [self.player setFrame:rect];
}


- (void)destroy {
    [self.player clearPlayersAndTimers];
}

#pragma mark - Public

- (void)playLive {
    [self reloadLive:nil];
}

- (void)pauseLive {
    [self.player pause];
}

- (void)reloadLive:(nonnull LoadPlayerCompletionBlock)completioin {
    [self reOpenPlayerWithLineIndex:-1 codeRate:nil completion:completioin];
}

- (void)switchPlayLine:(NSUInteger)Line completion:(LoadPlayerCompletionBlock)completioin {
    [self reOpenPlayerWithLineIndex:Line codeRate:self.roomData.curCodeRate completion:completioin];
}

- (void)switchPlayCodeRate:(NSString *)codeRate completion:(LoadPlayerCompletionBlock)completioin {
    [self reOpenPlayerWithLineIndex:self.roomData.curLine codeRate:codeRate completion:completioin];
}

- (void)switchAudioMode:(BOOL)audioMode {
    [self.player switchAudioMode:audioMode];
}

#pragma mark - Private

/// 播放或刷新直播 / 切换线路 / 切换其他清晰度
- (void)reOpenPlayerWithLineIndex:(NSInteger)lineIndex codeRate:(NSString *)codeRate completion:(LoadPlayerCompletionBlock)completioin {
    
    if (!self.viewModel.reOpening && !((PLVLivePlayerController *)self.player).linkMic) {
        self.viewModel.reOpening = YES;
        __weak typeof(self) weakSelf = self;
        [(PLVLivePlayerController *)self.player loadChannelWithLineIndex:lineIndex codeRate:codeRate completion:^{
            weakSelf.viewModel.reOpening = NO;
            if (completioin) {
                completioin(nil);
            }
        } failure:^(NSString *message) {
            weakSelf.viewModel.reOpening = NO;
            NSError *error = [NSError errorWithDomain:@"" code:-100 userInfo:@{NSLocalizedDescriptionKey:message}];
            if (completioin) {
                completioin(error);
            }
        }];
    }
}

- (void)updatelivePlayerState:(LivePlayerState)livePlayerState {
    self.viewModel.livePlayerState = livePlayerState;
    if ([self.view respondsToSelector:@selector(presenter:livePlayerStateDidChange:)]) {
        [self.view presenter:self livePlayerStateDidChange:livePlayerState];
    }
}

#pragma mark - <PLVPlayerControllerDelegate>

/// 刷新皮肤的多码率和多线路的按钮
- (void)playerController:(PLVPlayerController *)playerController codeRateItems:(NSMutableArray *)codeRateItems codeRate:(NSString *)codeRate lines:(NSUInteger)lines line:(NSInteger)line {
    //NSLog(@"player: codeRateItems %@ codeRate %@ lines %ld line %ld",codeRateItems,codeRate,lines,line);
    self.roomData.curLine = line;
    self.roomData.lines = lines;
    self.roomData.curCodeRate = codeRate;
    self.roomData.codeRateItems = codeRateItems;
    if ([self.view respondsToSelector:@selector(presenterChannelPlayOptionInfoDidUpdate:)]) {
        [self.view presenterChannelPlayOptionInfoDidUpdate:self];
    }
}

/// 加载主播放器失败（原因：1.网络请求失败；2.如果是直播，且该频道设置了限制条件）
- (void)playerController:(PLVPlayerController *)playerController loadMainPlayerFailure:(NSString *)message {
    if ([self.view respondsToSelector:@selector(presenter:loadMainPlayerFailure:)]) {
        [self.view presenter:self loadMainPlayerFailure:message];
    }
}

/// 播放器状态改变的Message消息回调
- (void)playerController:(PLVPlayerController *)playerController showMessage:(NSString *)message {
    if ([self.view respondsToSelector:@selector(presenter:showMessage:)]) {
        [self.view presenter:self showMessage:message];
    }
}

/// 改变视频所在窗口（主屏或副屏）的底色
- (void)changePlayerScreenBackgroundColor:(PLVPlayerController *)playerController {
    if ([self.view respondsToSelector:@selector(changePlayerScreenBackgroundColor:)]) {
        [self.view changePlayerScreenBackgroundColor:self];
    }
}

#pragma mark SubPlayer

/// 子播放器已准备好开始播放暖场视频
- (void)playerController:(PLVPlayerController *)playerController subPlaybackIsPreparedToPlay:(NSNotification *)notification {
    self.viewModel.warmUpPlaying = YES;
    [self updatelivePlayerState:LivePlayerStateWarmUp];
}

/// 子播放器已结束播放暖场视频
- (void)playerController:(PLVPlayerController *)playerController subPlayerDidFinish:(NSNotification *)notification {
    self.viewModel.warmUpPlaying = NO;
}

#pragma mark MainPlayer

/// 主播放器已准备好开始播放正片
- (void)playerController:(PLVPlayerController *)playerController mainPlaybackIsPreparedToPlay:(NSNotification *)notification {
    CGSize naturalSize = ((PLVIJKFFMoviePlayerController *)notification.object).naturalSize;
    if ([self.view respondsToSelector:@selector(presenter:videoSizeChange:)]) {
        [self.view presenter:self videoSizeChange:naturalSize];
    }

    self.viewModel.warmUpPlaying = NO;
    if ([self.view respondsToSelector:@selector(presenter:mainPlaybackIsPreparedToPlay:)]) {
        [self.view presenter:self mainPlaybackIsPreparedToPlay:notification.userInfo];
    }
}

/// 主播放器加载状态改变
- (void)playerController:(PLVPlayerController *)playerController mainPlayerLoadStateDidChange:(NSNotification *)notification {
    if ([self.view respondsToSelector:@selector(presenter:mainPlayerLoadStateDidChange:)]) {
        [self.view presenter:self mainPlayerLoadStateDidChange:self.viewModel.loadState];
    }
}

/// 主播放器播放状态改变
- (void)playerController:(PLVPlayerController *)playerController mainPlayerPlaybackStateDidChange:(NSNotification *)notification {
    if ([self.view respondsToSelector:@selector(presenter:mainPlayerPlaybackStateDidChange:)]) {
        [self.view presenter:self mainPlayerPlaybackStateDidChange:self.viewModel.playbackState];
    }
}

/// 主播放器已结束播放
- (void)playerController:(PLVPlayerController *)playerController mainPlayerPlaybackDidFinish:(NSNotification *)notification {
    if ([self.view respondsToSelector:@selector(presenter:mainPlayerPlaybackDidFinish:)]) {
        [self.view presenter:self mainPlayerPlaybackDidFinish:notification.userInfo];
    }
}

/// 主播器解析SEI信息回调
- (void)playerController:(PLVPlayerController *)playerController mainPlayerSeiDidChange:(long)timeStamp {
    if ([self.view respondsToSelector:@selector(presenter:mainPlayerSeiDidChange:)]) {
        [self.view presenter:self mainPlayerSeiDidChange:timeStamp];
    }
}

#pragma mark - <PLVLivePlayerControllerDelegate>

/// 定时器查询(每6秒)的直播流状态回调
- (void)livePlayerController:(PLVLivePlayerController *)livePlayer streamState:(PLVLiveStreamState)streamState {
    self.roomData.liveState = streamState;
    switch (streamState) {
        case PLVLiveStreamStateUnknown:
            [self updatelivePlayerState:LivePlayerStateUnknown];
            break;
        case PLVLiveStreamStateNoStream:
            if (!self.viewModel.warmUpPlaying) {
                [self updatelivePlayerState:LivePlayerStateEnd];
            }
            break;
        case PLVLiveStreamStateLive:
            [self updatelivePlayerState:LivePlayerStateLiving];
        break;
        case PLVLiveStreamStateStop:
            [self updatelivePlayerState:LivePlayerStatePause];
        break;
        default:
            break;
    }
}

/// 重连播放器回调
- (void)reconnectPlayer:(PLVLivePlayerController *)livePlayer {
    // 直播开始时，将触发此回调，通过reopenLive刷新直播
    [self reloadLive:nil];
}

/// 频道信息更新
- (void)liveVideoChannelDidUpdate:(PLVLiveVideoChannel *)channel {
    self.roomData.sessionId = channel.sessionId;
    if ([self.view respondsToSelector:@selector(presenterChannelInfoChanged:)]) {
        [self.view presenterChannelInfoChanged:self];
    }
}

/// 直播播放器的播放状态改变
- (void)livePlayerController:(PLVLivePlayerController *)livePlayer playing:(BOOL)playing {
    self.roomData.playing = playing;
}

@end
