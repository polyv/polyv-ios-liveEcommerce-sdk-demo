//
//  PLVChatTextModel.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/7.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVChatModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVChatTextModel : PLVChatModel

/// 信息内容
@property (nonatomic, copy) NSString *content;

/// socket text 消息
+ (instancetype)textModelWithUser:(NSDictionary *)user content:(NSString *)content;

/// 本地 text 消息
+ (instancetype)textModelWithNickName:(NSString *)nickName content:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
