//
//  PLVLiveRoomPresenter.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/20.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVLiveRoomData.h"

NS_ASSUME_NONNULL_BEGIN

/// 直播间业务类
@interface PLVLiveRoomPresenter : NSObject

@property (nonatomic, strong) PLVLiveRoomData *roomData;

/// 获取并更新当前房间频道信息
- (void)loadAndUpdateCurrentLiveRoomInfo;

/// 增加当前房间曝光度
- (void)increaseCurrentLiveRoomExposure;

@end

NS_ASSUME_NONNULL_END
