//
//  PLVChatModel.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/7.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PLVChatUserType) {
    PLVChatUserTypeUnknown   = 0,
    
    PLVChatUserTypeStudent   = 1, // 普通观众
    PLVChatUserTypeSlice     = 2, // 云课堂学员
    PLVChatUserTypeViewer    = 3, // 客户端的参与者
    
    PLVChatUserTypeGuest     = 4, // 嘉宾
    PLVChatUserTypeTeacher   = 5, // 讲师
    PLVChatUserTypeAssistant = 6, // 助教
    PLVChatUserTypeManager   = 7, // 管理员
    
    PLVChatUserTypeDummy     = 8
};

@interface PLVChatUser : NSObject

/// 用户头衔
@property (nonatomic, strong) NSString *actor;
/// 用户头衔字体颜色
@property (nonatomic, strong) UIColor *actorTextColor;
/// 用户头衔背景颜色
@property (nonatomic, strong) UIColor *actorBackgroundColor;
/// 用户昵称
@property (nonatomic, strong) NSString *nickName;
/// 用户头像
@property (nonatomic, strong) NSString *avatar;

/// 是否被禁言
@property (nonatomic, assign) BOOL banned;

/// 用户类型
@property (nonatomic, assign) PLVChatUserType userType;

/// 用户Id
@property (nonatomic, strong) NSString *userId;

/// 特殊身份
@property (nonatomic, assign) BOOL specialIdentity;

- (instancetype)initWithUserInfo:(NSDictionary *)user;

@end

@interface PLVChatModel : NSObject

/// 消息id
@property (nonatomic, copy) NSString *msgId;

/// 消息时间戳
@property (nonatomic, copy) NSString *time;

/// 用户信息
@property (nonatomic, strong) PLVChatUser *user;

@end

NS_ASSUME_NONNULL_END
