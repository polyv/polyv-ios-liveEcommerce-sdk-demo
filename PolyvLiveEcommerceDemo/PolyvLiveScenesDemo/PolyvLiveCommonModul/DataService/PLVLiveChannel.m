//
//  PLVLiveChannel.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/26.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVLiveChannel.h"
#import <PolyvCloudClassSDK/PLVLiveVideoConfig.h>

@interface PLVLiveWatchUser ()

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy)  NSString *nickName;
@property (nonatomic, copy)  NSString *role;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *actor;

@end

@implementation PLVLiveWatchUser

+ (instancetype)watchUserWithUserId:(NSString *)userId nickName:(NSString *)nickName avatarUrl:(NSString *)avatarUrl {
    if (!userId) {
        NSUInteger userIdInt =(NSUInteger)[[NSDate date] timeIntervalSince1970];
        userId = @(userIdInt).stringValue;
    }
    if (!nickName) {
        nickName = [@"手机用户/" stringByAppendingFormat:@"%05d",arc4random() % 100000];
    }
    if (!avatarUrl) {
        avatarUrl = @"https://www.polyv.net/images/effect/effect-device.png";
    }
    
    PLVLiveWatchUser *watchUser = [[PLVLiveWatchUser alloc] init];
    watchUser.userId = userId;
    watchUser.nickName = nickName;
    watchUser.avatarUrl = avatarUrl;
    watchUser.role = @"student";

    return watchUser;
}

@end

@interface PLVLiveChannel ()

@property (nonatomic, strong) PLVLiveAccount *account;
@property (nonatomic, strong) PLVLiveWatchUser *watchUser;

@property (nonatomic, copy) NSString *channelId;

@property (nonatomic, copy) NSString *vid;

@end

@implementation PLVLiveChannel

+ (instancetype)channelWithChannelId:(NSString *)channelId watchUser:(PLVLiveWatchUser *)watchUser account:(PLVLiveAccount *)account {
    PLVLiveChannel *channel = [[PLVLiveChannel alloc] init];
    channel.channelId = channelId;
    channel.watchUser = watchUser;
    channel.account = account;
    
    // 兼容sdk配置
    [PLVLiveVideoConfig liveConfigWithUserId:account.userId appId:account.appId appSecret:account.appSecret];
    PLVLiveVideoConfig.sharedInstance.channelId = channelId;
    
    return channel;
}

+ (instancetype)channelWithChannelId:(NSString *)channelId vid:(NSString *)vid account:(PLVLiveAccount *)account {
    PLVLiveChannel *channel = [[PLVLiveChannel alloc] init];
    channel.channelId = channelId;
    channel.vid = vid;
    channel.account = account;
    
    // 兼容sdk配置
    [PLVLiveVideoConfig liveConfigWithUserId:account.userId appId:account.appId appSecret:account.appSecret];
    PLVLiveVideoConfig.sharedInstance.channelId = channelId;
    
    return channel;
}

@end
