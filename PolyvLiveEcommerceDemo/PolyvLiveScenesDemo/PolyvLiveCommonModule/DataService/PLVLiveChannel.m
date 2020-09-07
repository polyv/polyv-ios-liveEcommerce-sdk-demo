//
//  PLVLiveChannel.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/26.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVLiveChannel.h"
#import <PolyvCloudClassSDK/PLVLiveVideoConfig.h>

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
    PLVLiveVideoConfig.sharedInstance.channelId = channelId;
    [PLVLiveVideoConfig liveConfigWithUserId:account.userId appId:account.appId appSecret:account.appSecret];
    
    return channel;
}

+ (instancetype)channelWithChannelId:(NSString *)channelId vid:(NSString *)vid account:(PLVLiveAccount *)account {
    PLVLiveChannel *channel = [[PLVLiveChannel alloc] init];
    channel.channelId = channelId;
    channel.vid = vid;
    channel.account = account;
    
    // 兼容sdk配置
    PLVLiveVideoConfig.sharedInstance.channelId = channelId;
    PLVLiveVideoConfig.sharedInstance.vodId = vid;
    [PLVLiveVideoConfig liveConfigWithUserId:account.userId appId:account.appId appSecret:account.appSecret];
    
    return channel;
}

@end
