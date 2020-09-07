//
//  PLVECPlaybackViewController.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/4/30.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVLiveRoomData.h"

NS_ASSUME_NONNULL_BEGIN

/// 直播带货场景回放页
@interface PLVECPlaybackViewController : UIViewController

/// 是否横屏显示
@property (nonatomic, assign) BOOL landscapeMode;

/// 初始化当前控制器方法
- (instancetype)initWithLiveRoomData:(PLVLiveRoomData *)roomData;

@end

NS_ASSUME_NONNULL_END
