//
//  PLVECLivePlayerViewController.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/23.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVLivePlayerPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@class PLVECLivePlayerViewController;

@protocol PLVECLivePlayerProtocol <NSObject>

@optional

/// 刷新皮肤的多码率和多线路的按钮
- (void)playerController:(PLVECLivePlayerViewController *)playerController
           codeRateItems:(NSArray <NSString *>*)codeRateItems
                codeRate:(NSString *)codeRate
                   lines:(NSUInteger)lines
                    line:(NSInteger)line;

@end

/// 直播带货直播播放器视图控制器
@interface PLVECLivePlayerViewController : UIViewController

@property (nonatomic, weak) id<PLVECLivePlayerProtocol> delegate;

@property (nonatomic, strong, readonly) PLVLivePlayerPresenter *presenter;

/// 播放直播
- (void)playLive;

/// 暂停直播
- (void)pauseLive;

/// 播放/刷新/重新加载直播
- (void)reloadLive;

/// 切换线路
- (void)switchPlayLine:(NSUInteger)Line showHud:(BOOL)showHud;

/// 切换码率
- (void)switchPlayCodeRate:(NSString *)codeRate showHud:(BOOL)showHud;

/// 切换音频模式
- (void)switchAudioMode:(BOOL)audioMode;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
