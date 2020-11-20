//
//  PLVChatroomPresenter.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/12.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVSocketServiceProtocol.h"
#import "PLVChatroomViewMode.h"
#import "PLVLiveRoomData.h"

NS_ASSUME_NONNULL_BEGIN

@class PLVChatroomPresenter;

/// 聊天室视图协议
@protocol PLVECChatroomViewProtocol <NSObject>

@property (nonatomic, weak) PLVChatroomPresenter *presenter;

@property (nonatomic, strong) UITableView *tableView;

- (void)scrollsToBottom:(BOOL)animated;

- (void)showWelcomeView:(NSString *)message duration:(NSTimeInterval)duration;

/// 加载聊天记录（调用方法 '-loadHistoryDataWithCount:'）成功回调
/// first 表示是否第一次加载聊天记录
/// noMore： YES - 没有更多历史聊天记录；NO - 还有更多历史聊天记录
- (void)loadHistoryDataSuccessAtFirstTime:(BOOL)first hasNoMoreMessage:(BOOL)noMore;

/// 加载聊天记录（调用方法 '-loadHistoryDataWithCount:'）失败回调
- (void)loadHistoryDataFailure;

@end

/// 聊天室业务抽象基类
@interface PLVChatroomPresenter : NSObject <PLVSocketServiceProtocol,UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readonly) PLVChatroomViewMode *viewModel;

@property (nonatomic, weak) id<PLVECChatroomViewProtocol> view;

@property (nonatomic, strong) PLVLiveRoomData *roomData;

#pragma mark - External API

/// 发言消息，生成发言模型并提交该消息
- (BOOL)speakMessage:(NSString *)message;

/// 获取 count 条历史聊天记录
- (void)loadHistoryDataWithCount:(NSInteger)count;

/// 点赞，会更新roomData中点赞数同时对点赞消息做优化提交
- (void)likeAction;

/// 退出前调用
- (void)destroy;

#pragma mark - Internal API

#pragma mark 子类需重写的方法

/// 发言消息CellModel类型，返回类需为 PLVChatBaseCell 子类型
- (Class)speakChatCellClass;

/// 发言消息CellModel类型，返回类需为 PLVChatCellModel 子类型
- (Class)speakChatCellModelClass;

/// 图片消息Cell类型，返回类需为 PLVChatBaseCell 子类型
- (Class)imageChatCellClass;

/// 图片消息CellModel类型，返回类需为 PLVChatCellModel 子类型
- (Class)imageChatCellModelClass;

#pragma mark Socket Event

/// 有用户登陆事件
- (void)loginEvent:(NSDictionary *)data;

/// 有用户登出事件
- (void)logoutEvent:(NSDictionary *)data;

/// 公告事件
- (void)bulletinEvent:(NSDictionary *)data;

/// 用户设置昵称事件
- (void)setNickEvent:(NSDictionary *)data;

/// 收到发言消息事件
- (void)speakMessageEvent:(NSDictionary *)data;

/// 收到图片消息事件
- (void)imageMessageEvent:(NSDictionary *)data;

/// 关闭或打开聊天室事件
- (void)closeChatroomEvent:(NSDictionary *)data;

/// 删除一条消息事件
- (void)removeContentEvent:(NSDictionary *)data;

/// 清空所有消息事件
- (void)removeHistoryEvent;

/// 禁言事件
- (void)addShieldEvent:(NSDictionary *)data;

/// 解禁言事件
- (void)removeShieldEvent:(NSDictionary *)data;

/// 踢人事件
- (void)kickEvent:(NSDictionary *)data;

/// 点赞事件
- (void)likesEvent:(NSDictionary *)data;

/// 送花事件
- (void)flowersEvent:(NSDictionary *)data;

/// 打赏事件
- (void)rewardEvent:(NSDictionary *)data;

/// 讲师回答事件
- (void)teacherAnswerEvent:(NSDictionary *)data;

/// 学生提问事件
- (void)studentQuestionEvent:(NSDictionary *)data;

#pragma mark View Event

/// 数据源更新时调用，刷行view数据源和滚动到底部
- (void)reloadData;

/// 出队登陆的用户信息，该方法会被定时调用
- (void)dequeueWelcomeMessage;

/// 会调用 view 的 -showWelcomeView: 方法
- (void)showWelcomeMessage:(NSString *)nickNames;

@end

NS_ASSUME_NONNULL_END
