//
//  PLVSceneLoginManager.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/23.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PolyvCloudClassSDK/PLVLiveDefine.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVSceneLoginManager : NSObject

/// 登录直播间
/// @param channelId 频道号
/// @param completion 登录成功
/// @param failure 登录失败
+ (void)loginLiveRoom:(NSString *)channelId
           completion:(void (^)(NSString *liveType, PLVLiveStreamState liveState, NSDictionary *data))completion
              failure:(void (^)(NSError *error))failure;

/// 登录回放直播间
/// @param channelId 频道号
/// @param vid 回放视频id
/// @param completion 登录成功
/// @param failure 登录失败
+ (void)loginPlaybackLiveRoom:(NSString *)channelId
                          vid:(NSString *)vid
                   completion:(void (^)(BOOL vodType, NSDictionary *data))completion
                      failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
