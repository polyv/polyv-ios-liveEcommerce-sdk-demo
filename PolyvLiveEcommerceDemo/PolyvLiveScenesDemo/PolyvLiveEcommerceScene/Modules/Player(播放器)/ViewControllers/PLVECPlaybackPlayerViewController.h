//
//  PLVECPlayerViewController.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/23.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVPlaybackPlayerPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVECPlaybackPlayerViewControlDelegate <NSObject>

@optional

/// 更新回放进度
- (void)updateDowloadProgress:(CGFloat)dowloadProgress playedProgress:(CGFloat)playedProgress currentPlaybackTime:(NSString *)currentPlaybackTime duration:(NSString *)duration;

@end

/// 直播带货回放播放器视图控制器
@interface PLVECPlaybackPlayerViewController : UIViewController

@property (nonatomic, strong, readonly) PLVPlaybackPlayerPresenter *presenter;

@property (nonatomic, assign) id<PLVECPlaybackPlayerViewControlDelegate> delegate;

/// 横屏显示
@property (nonatomic, assign) BOOL landscapeMode;

- (void)play;

- (void)pause;

- (void)seek:(NSTimeInterval)time;

- (void)speedRate:(NSTimeInterval)speed;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
