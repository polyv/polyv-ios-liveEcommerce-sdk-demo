//
//  PLVLiveRoomData.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/26.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PolyvCloudClassSDK/PLVLiveDefine.h>
#import <PolyvCloudClassSDK/PLVLiveVideoChannelMenuInfo.h>
#import "PLVLiveChannel.h"

#define KEYPATH_LIVEROOM_CHANNEL @"channelInfo"
#define KEYPATH_LIVEROOM_LIKECOUNT @"likeCount"
#define KEYPATH_LIVEROOM_VIEWCOUNT @"watchViewCount"
#define KEYPATH_LIVEROOM_LIVESTATE @"liveState"
#define KEYPATH_LIVEROOM_LINES @"lines"
#define KEYPATH_LIVEROOM_DURATION @"duration"
#define KEYPATH_LIVEROOM_PLAYING @"playing"

NS_ASSUME_NONNULL_BEGIN

/// 直播间数据（房间信息、状态）
@interface PLVLiveRoomData : NSObject

/// 直播频道信息（配置信息）
@property (nonatomic, strong, readonly) PLVLiveChannel *channel;

/// 直播频道信息（后台信息）
@property (nonatomic, strong, readonly) PLVLiveVideoChannelMenuInfo *channelInfo;

/// chat 私有域名
@property (nonatomic, copy, readonly) NSString *chatDomain;
/// chatApi 私有域名
@property (nonatomic, copy, readonly) NSString *chatApiDomain;

/// 点赞数
@property (nonatomic, assign) NSUInteger likeCount;

/// 观看热度
@property (nonatomic, assign) NSUInteger watchViewCount;

/// 音频模式
@property (nonatomic, assign) BOOL audioMode;

/// 当前线路
@property (nonatomic, assign) NSUInteger curLine;
/// 多线路
@property (nonatomic, assign) NSUInteger lines;
/// 当前码率
@property (nonatomic, copy) NSString *curCodeRate;
/// 码率列表
@property (nonatomic, copy) NSArray<NSString *> *codeRateItems;

/// 播放状态
@property (nonatomic, assign) BOOL playing;

#pragma mark live

/// 直播状态
@property (nonatomic, assign) PLVLiveStreamState liveState;

/// 当前直播 sessionId
@property (nonatomic, copy) NSString *sessionId;

/// 直播房间号（登录聊天室）
@property (nonatomic, copy) NSString *roomId;

#pragma mark playback

/// 视频时长
@property (nonatomic, assign) NSTimeInterval duration;

#pragma mark Init method

- (instancetype)initWithLiveChannel:(PLVLiveChannel *)channel;

+ (instancetype)liveRoomDataWithLiveChannel:(PLVLiveChannel *)channel;

#pragma mark API

/// 更新频道信息
- (void)updateChannelInfo:(PLVLiveVideoChannelMenuInfo *)channelInfo;

/// 设置频道私有域名
- (void)setPrivateDomainWithData:(NSDictionary *)data;

#pragma mark - 便捷属性获取

/// 频道号，等同 self.channel.channelId
- (NSString *)channelId;

/// 视频 vid，等同 self.channel.vid
- (NSString *)vid;

/// 帐号 userId，等同 self.channel.account.userId
- (NSString *)userIdForAccount;

/// 观看用户 userId，等同 self.channel.watchUser.userId
- (NSString *)userIdForWatchUser;

/// 帐号信息，等同 self.channel.account
- (PLVLiveAccount *)account;

/// 观看用户信息，等同 self.channel.watchUser
- (PLVLiveWatchUser *)watchUser;

@end

NS_ASSUME_NONNULL_END
