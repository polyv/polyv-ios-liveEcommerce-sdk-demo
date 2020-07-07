//
//  PLVLiveChannel.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/26.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVLiveSDKConfig.h"

/// 直播观看用户信息
@interface PLVLiveWatchUser : NSObject

/// 用户Id
@property (nonatomic, copy, readonly) NSString *userId;

/// 用户昵称
@property (nonatomic, copy, readonly)  NSString *nickName;

/// 用户头像地址
@property (nonatomic, copy, readonly) NSString *avatarUrl;

/// 用户头衔
@property (nonatomic, copy, readonly) NSString *actor;

/// 用户角色
@property (nonatomic, copy, readonly)  NSString *role;

/// 生成一个观看用户对象
+ (instancetype)watchUserWithUserId:(NSString *)userId nickName:(NSString *)nickName avatarUrl:(NSString *)avatarUrl;

@end

/// 直播频道信息（初始化配置）
@interface PLVLiveChannel : NSObject

/// 直播帐号
@property (nonatomic, strong, readonly) PLVLiveAccount *account;

/// 直播观看用户
@property (nonatomic, strong, readonly) PLVLiveWatchUser *watchUser;

/// 直播频道号（主频道号）
@property (nonatomic, copy, readonly) NSString *channelId;

/// 直播回放视频id（回放）
@property (nonatomic, copy, readonly) NSString *vid;

/// 播放视频优先解码方式，默认YES，硬解码
@property (nonatomic, assign) BOOL videoToolBox;

/// 初始化一个直播频道对象
/// @param channelId 频道号
/// @param watchUser 观看用户信息
/// @param account 帐号信息
+ (instancetype)channelWithChannelId:(NSString *)channelId watchUser:(PLVLiveWatchUser *)watchUser account:(PLVLiveAccount *)account;

/// 初始化一个直播回放频道对象
/// @param channelId 频道号
/// @param vid 视频vid
/// @param account 帐号信息
+ (instancetype)channelWithChannelId:(NSString *)channelId vid:(NSString *)vid account:(PLVLiveAccount *)account;

@end
