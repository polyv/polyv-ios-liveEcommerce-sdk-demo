//
//  PLVChatroomViewMode.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/12.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVChatCellModel.h"

/// 聊天室视图模型（提供视图数据源及数据管理）
@interface PLVChatroomViewMode : NSObject

/// 聊天室消息数据源
@property (nonatomic, strong, readonly) NSMutableArray<PLVChatCellModel *> *dataSource;
/// 聊天室消息数据源最大数据量，超过后丢弃最前的数据，默认值 10000
@property (nonatomic, assign) NSUInteger maxCount;

/// 私有聊天室消息数据源（学生端）
@property (nonatomic, strong, readonly) NSMutableArray<PLVChatCellModel *> *privateChatDataSource;

/// 登陆用户缓存队列
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *loginUserCacheQueue;
/// 登陆用户（自己）
@property (nonatomic, strong) NSDictionary *loginUserOfMe;

/// 在线人数
@property (nonatomic, assign) NSUInteger onlineCount;

/// 房间状态
@property (nonatomic, getter=isClosed) BOOL closed;

/// 是否被禁言
@property (nonatomic, getter=isBanned) BOOL banned;

#pragma mark - dataSource handle

/// 添加模型到 消息数据源 或 消息缓存队列
- (void)addModel:(PLVChatCellModel *)model toCache:(BOOL)cache;

/// 添加模型到 消息数据源 指定位置
- (void)insertModel:(PLVChatCellModel *)model atIndex:(NSUInteger)index;

/// 移除 消息数据源 和 消息缓存队列 中指定模型
- (void)removeModel:(PLVChatCellModel *)model;

/// 清空 消息数据源 和 消息缓存队列
- (void)removeAllModels;

/// 消息缓存队列 出队数据至 消息数据源
- (BOOL)dequeueChatMessage;

#pragma mark - loginUserCacheQueue handle

/// 添加登陆用户信息
- (void)enqueueLoginUser:(NSDictionary *)loginUser me:(BOOL)me;

@end
