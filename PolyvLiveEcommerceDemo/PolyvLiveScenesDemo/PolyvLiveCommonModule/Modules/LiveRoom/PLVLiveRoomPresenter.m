//
//  PLVLiveRoomPresenter.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/20.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVLiveRoomPresenter.h"
#import <PolyvCloudClassSDK/PLVLiveVideoAPI.h>

@implementation PLVLiveRoomPresenter

- (void)loadAndUpdateCurrentLiveRoomInfo {
    NSString *channelId = self.roomData.channelId;
    if (!channelId || ![channelId isKindOfClass:NSString.class]) {
        return;
    }
    
    static int suceess = 0;
    if (suceess == -1) {
        return;
    }
    suceess = -1;
    __weak typeof(self)weakSelf = self;
    [PLVLiveVideoAPI getChannelMenuInfos:channelId.integerValue completion:^(PLVLiveVideoChannelMenuInfo *channelMenuInfo) {
        suceess = 1;
        [weakSelf.roomData updateChannelInfo:channelMenuInfo];
    } failure:^(NSError *error) {
        suceess = 0;
        NSLog(@"频道菜单获取失败！%@",error);
    }];
}

- (void)increaseCurrentLiveRoomExposure {
    NSString *channelId = self.roomData.channelId;
    if (!channelId || ![channelId isKindOfClass:NSString.class]) {
        return;
    }
    
    // 避免短时间高频调用
    static int suceess = 0;
    if (suceess == -1) {
        return;
    }
    suceess = -1;
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PLVLiveVideoAPI increaseViewerWithChannelId:channelId times:1 completion:^(NSInteger viewers){
            suceess = 1;
            weakSelf.roomData.watchViewCount ++;
            NSLog(@"exposure:%ld",viewers);
        } failure:^(NSError * _Nonnull error) {
            suceess = 0;
            NSLog(@"increaseExposure, error:%@",error.localizedDescription);
        }];
    });
}

@end
