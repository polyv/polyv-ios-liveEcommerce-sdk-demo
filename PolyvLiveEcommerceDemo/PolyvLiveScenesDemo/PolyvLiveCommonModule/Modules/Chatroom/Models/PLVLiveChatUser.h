//
//  PLVLiveChatUser.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/13.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVLiveUser.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 直播聊天室用户类
@interface PLVLiveChatUser : PLVLiveUser

/// 用户头衔字体颜色
@property (nonatomic, strong) UIColor *actorTextColor;

/// 用户头衔背景颜色
@property (nonatomic, strong) UIColor *actorBackgroundColor;

/// 是否被禁言
@property (nonatomic, assign) BOOL banned;

/// 特殊身份
@property (nonatomic, assign) BOOL specialIdentity;

- (instancetype)initWithUserInfo:(NSDictionary *)user;

@end

NS_ASSUME_NONNULL_END
