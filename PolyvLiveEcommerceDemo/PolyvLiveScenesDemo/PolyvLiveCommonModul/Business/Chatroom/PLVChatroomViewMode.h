//
//  PLVChatroomViewMode.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/12.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVCellModel.h"

/// 聊天室视图模型（提供视图数据源及数据管理）
@interface PLVChatroomViewMode : NSObject

/// 聊天室消息数据源
@property (nonatomic, strong, readonly) NSMutableArray<PLVCellModel *> *dataSource;

/// 刷新数据源标识，可通过观察该值的变化判断数据源是否更新
@property (nonatomic, assign, readonly) NSUInteger refreshFlag;

/// 更新数据源数据频率，默认 0.5s
@property (nonatomic, assign) NSTimeInterval refreshRate;

/// 数据源最大数据量，超过后丢弃最前的数据，默认值 1000
@property (nonatomic, assign) NSUInteger maxCount;

/// 房间状态
@property (nonatomic, getter=isClosed) BOOL closed;

#pragma mark - data handle

/// 添加模型，默认进缓存队列
- (void)addModel:(PLVCellModel *)model;

- (void)addModel:(PLVCellModel *)model enqueue:(BOOL)enqueue;

- (void)updateModel:(PLVCellModel *)model;

- (void)removeModel:(PLVCellModel *)model;

- (void)removeAllModels;

- (void)insertModel:(PLVCellModel *)model atIndex:(NSUInteger)index;

/// 缓存聊天消息出队
- (BOOL)dequeueChatMessage;

@end
