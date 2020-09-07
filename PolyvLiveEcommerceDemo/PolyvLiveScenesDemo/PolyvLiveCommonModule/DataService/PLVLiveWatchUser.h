//
//  PLVLiveWatchUser.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/13.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVLiveUser.h"

/// 直播观看用户类
@interface PLVLiveWatchUser : PLVLiveUser

@property (nonatomic, copy) NSString *getCup;

/// 生成一个观看用户对象，默认 userType 为 PLVLiveUserTypeStudent
+ (instancetype)watchUserWithUserId:(NSString *)userId nickName:(NSString *)nickName avatarUrl:(NSString *)avatarUrl;

@end
