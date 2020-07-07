//
//  PLVChatroomPresenter.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/12.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVChatroomViewMode.h"
#import "PLVLiveRoomData.h"
#import "PLVSocketManager.h"

NS_ASSUME_NONNULL_BEGIN

@class PLVChatroomPresenter;

/// 聊天室控制器协议，实现特定场景业务类
@protocol PLVChatroomDataProcessorProtocol <NSObject>

/// 出队登陆用户信息，内部按照一定策略出队
- (void)presenter:(PLVChatroomPresenter *)presenter dequeueLoginUser:(NSString *)nickNames;

//- (void)presenter:(PLVChatroomPresenter *)presenter dequeueLoginUser:(NSArray *)nickNames me:(BOOL)me;

- (void)presenter:(PLVChatroomPresenter *)presenter dataSourceUpdate:(NSArray<PLVCellModel *> *)dataSource;

@end

/// 聊天室业务类
@interface PLVChatroomPresenter : NSObject

@property (nonatomic, strong, readonly) PLVChatroomViewMode *viewModel;

@property (nonatomic, weak) id<PLVChatroomDataProcessorProtocol> dataProcessor;

@property (nonatomic, strong) PLVLiveRoomData *roomData;

@property (nonatomic, strong) PLVSocketManager *socketManager;

/// 添加登录消息，通过 -presenter:dequeueLoginUser: 出队用户信息
- (void)enqueueLoginUser:(NSDictionary *)loginUser me:(BOOL)me;

/// 立即触发 -presenter:dataSourceUpdate: 回调
- (void)reloadData;

/// 提交本地发言
- (BOOL)emitSpeakMessage:(NSString *)content;

/// 点赞，内部会更新点赞数同时对点赞消息做优化提交
- (void)likeAction;

/// 退出前清理资源
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
