//
//  PLVLiveWatchUser.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/13.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVLiveWatchUser.h"

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
    watchUser.role = kPLVLiveUserTypeStudent;
    watchUser.userType = PLVLiveUserTypeStudent;

    return watchUser;
}

@end
