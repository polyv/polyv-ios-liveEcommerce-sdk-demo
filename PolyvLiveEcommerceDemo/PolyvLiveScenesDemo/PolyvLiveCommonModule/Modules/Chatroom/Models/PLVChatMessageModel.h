//
//  PLVChatMessageModel.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/7.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVLiveChatUser.h"

NS_ASSUME_NONNULL_BEGIN

/// 聊天室信息模型抽象基类
@interface PLVChatMessageModel : NSObject

/// 消息id
@property (nonatomic, copy) NSString *msgId;

/// 消息时间戳
@property (nonatomic, copy) NSString *time;

/// 用户信息
@property (nonatomic, strong) PLVLiveChatUser *user;

@end

NS_ASSUME_NONNULL_END
