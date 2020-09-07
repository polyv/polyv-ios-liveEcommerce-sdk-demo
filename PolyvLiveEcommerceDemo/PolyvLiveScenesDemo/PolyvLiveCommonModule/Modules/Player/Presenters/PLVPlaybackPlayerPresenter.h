//
//  PLVPlaybackPlayerPresenter.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/9.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVBasePlayerPresenter.h"
#import "PLVPlaybackPlayerViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class PLVPlaybackPlayerPresenter;
@protocol PLVPlaybackPlayerPresenterDelegate <PLVPlayerPresenterDelegate>

@optional

/// 更新回放进度
- (void)updateDowloadProgress:(CGFloat)dowloadProgress playedProgress:(CGFloat)playedProgress currentPlaybackTime:(NSString *)currentPlaybackTime duration:(NSString *)duration;

/// 主播放器Seek完成
- (void)presenter:(PLVPlaybackPlayerPresenter *)presenter mainPlayerDidSeekComplete:(NSDictionary *)dataInfo;

/// 主播放器精准Seek完成
- (void)presenter:(PLVPlaybackPlayerPresenter *)presenter mainPlayerAccurateSeekComplete:(NSDictionary *)dataInfo;

@end

@interface PLVPlaybackPlayerPresenter : PLVBasePlayerPresenter

@property (nonatomic, strong, readonly) PLVPlaybackPlayerViewModel *viewModel;

@property (nonatomic, weak) id<PLVPlaybackPlayerPresenterDelegate> view;

/// 播放
- (void)play;

/// 暂停
- (void)pause;

/// seek 至某一时间
- (void)seek:(NSTimeInterval)time;

/// 倍速播放
- (void)speedRate:(NSTimeInterval)speed;

@end

NS_ASSUME_NONNULL_END
