//
//  PLVSceneLoginManager.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/23.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVSceneLoginManager.h"
#import <PolyvCloudClassSDK/PLVLiveVideoAPI.h>
#import "PLVLiveSDKConfig.h"

@implementation PLVSceneLoginManager

+ (void)loginLiveRoom:(NSString *)channelId completion:(void (^)(NSString * _Nonnull, PLVLiveStreamState, NSDictionary *))completion failure:(void (^)(NSError * _Nonnull))failure {
    PLVLiveAccount *account = PLVLiveSDKConfig.sharedSDK.account;
    if (!channelId || !account) {
        if (failure) {
            NSError *err = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"参数不能为空"}];
            failure(err);
        }
        return;
    }
    
    [PLVLiveVideoAPI verifyPermissionWithChannelId:channelId.integerValue vid:@"" appId:account.appId userId:account.userId appSecret:account.appSecret completion:^(NSDictionary * _Nonnull data) {
        [PLVLiveVideoAPI liveStatus2:channelId completion:^(NSString * _Nonnull liveType, PLVLiveStreamState liveState) {
            if (completion) {
                completion(liveType, liveState, data);
            }
        } failure:failure];
    } failure:failure];
}

+ (void)loginPlaybackLiveRoom:(NSString *)channelId vid:(NSString *)vid completion:(void (^)(BOOL, NSDictionary *))completion failure:(void (^)(NSError * _Nonnull))failure {
    PLVLiveAccount *account = PLVLiveSDKConfig.sharedSDK.account;
    if (!channelId || !vid || !account) {
        if (failure) {
            NSError *err = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"参数不能为空"}];
            failure(err);
        }
        return;
    }
    
    [PLVLiveVideoAPI verifyPermissionWithChannelId:channelId.integerValue vid:vid appId:account.appId userId:account.userId appSecret:account.appSecret completion:^(NSDictionary * _Nonnull data) {
        [PLVLiveVideoAPI getVodType:vid completion:^(BOOL vodType) {
            if (completion) {
                completion(vodType, data);
            }
        } failure:failure];
    } failure:failure];
}


@end
