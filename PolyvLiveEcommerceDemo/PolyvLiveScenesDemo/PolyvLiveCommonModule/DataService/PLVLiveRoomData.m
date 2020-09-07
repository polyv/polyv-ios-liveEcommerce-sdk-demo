//
//  PLVLiveRoomData.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/26.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVLiveRoomData.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>

@interface PLVLiveRoomData ()

@property (nonatomic, strong) PLVLiveChannel *channel;
@property (nonatomic, strong) PLVLiveVideoChannelMenuInfo *channelInfo;
@property (nonatomic, copy) NSString *chatDomain;
@property (nonatomic, copy) NSString *chatApiDomain;

@end

@implementation PLVLiveRoomData

- (instancetype)init
{
    NSLog(@"PLVLiveRoomData 初始化失败，请调用 %@ 或 %@ 方法初始化", NSStringFromSelector(@selector(initWithLiveChannel:)),NSStringFromSelector(@selector(liveRoomDataWithLiveChannel:)));
    return nil;
}

#pragma mark Init method

- (instancetype)initWithLiveChannel:(PLVLiveChannel *)channel {
    self = [super init];
    if (self) {
        self.channel = channel;
    }
    return self;
}

+ (instancetype)liveRoomDataWithLiveChannel:(PLVLiveChannel *)channel {
    return [[PLVLiveRoomData alloc] initWithLiveChannel:channel];
}

#pragma mark API

- (void)updateChannelInfo:(PLVLiveVideoChannelMenuInfo *)channelInfo {
    self.channelInfo = channelInfo;
    self.likeCount = channelInfo.likes.unsignedIntegerValue;
    self.watchViewCount = channelInfo.pageView.unsignedIntegerValue;
}

- (void)setPrivateDomainWithData:(NSDictionary *)data {
    if ([data isKindOfClass:NSDictionary.class] && data.count > 0) {
        self.chatDomain = PLV_SafeStringForDictKey(data, @"chatDomain");
        self.chatApiDomain = PLV_SafeStringForDictKey(data, @"chatApiDomain");
    }
}

#pragma mark - 便捷属性获取

- (NSString *)channelId {
    return self.channel.channelId;
}

- (NSString *)vid {
    return self.channel.vid;
}

- (NSString *)userIdForAccount {
    return self.channel.account.userId;
}

- (NSString *)userIdForWatchUser {
    return self.channel.watchUser.userId;
}

- (PLVLiveAccount *)account {
    return self.channel.account;
}

- (PLVLiveWatchUser *)watchUser {
    return self.channel.watchUser;
}

@end
