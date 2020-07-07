//
//  PLVECLivePlayerViewController.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/23.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVLiveRoomData.h"

NS_ASSUME_NONNULL_BEGIN

/// 直播带货直播播放器视图控制器
@interface PLVECLivePlayerViewController : UIViewController

@property (nonatomic, strong) PLVLiveRoomData *roomData;

/// 横屏显示
@property (nonatomic, assign) BOOL landscapeMode;

/// 播放直播
- (void)playLive;

/// 暂停直播
- (void)pauseLive;

/// 播放/刷新/重新加载直播
- (void)reloadLive;

/// 切换线路
- (void)switchPlayLine:(NSUInteger)Line;

/// 切换码率
- (void)switchPlayCodeRate:(NSString *)codeRate;

/// 切换音频模式
- (void)switchAudioMode:(BOOL)audioMode;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
