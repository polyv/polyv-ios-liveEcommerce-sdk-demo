//
//  PLVChatroomPresenter.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/12.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVChatroomPresenter.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>
#import <PolyvCloudClassSDK/PLVLiveVideoAPI.h>
#import "PLVChatTextModel.h"
#import "PLVChatImageModel.h"
#import "PLVChatBaseCell.h"
#import "PLVSocketManager.h"

static inline void plv_dict_set(NSMutableDictionary *mDict, id aKey, id anObject) {
    if (anObject) {
        [mDict setObject:anObject forKey:aKey];
    }
}

@interface PLVChatroomPresenter () <PLVSocketObserverProtocol>

@property (nonatomic, strong) PLVChatroomViewMode *viewModel;

// 聊天室管理socket的生命周期，信令服务协议交由socketManager处理
@property (nonatomic, strong) id<PLVSocketServiceProtocol> socketManager;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger timing;

@property (nonatomic, strong) NSTimer *likeTimer;
@property (nonatomic, assign) NSUInteger likeTiming;

@property (nonatomic, assign) NSUInteger likeCountOfMe;
@property (nonatomic, assign) NSUInteger likeCountOfHttp;

@property (nonatomic, assign) BOOL loadingHistory;
@property (nonatomic, assign) BOOL noMoreHistory;

@end

static const NSTimeInterval ChatroomRefreshFrequency = 0.5;

@implementation PLVChatroomPresenter

#pragma mark - Setter

- (void)setRoomData:(PLVLiveRoomData *)roomData {
    _roomData = roomData;
    if ([_socketManager isKindOfClass:PLVSocketManager.class]) {
        [(PLVSocketManager *)_socketManager setRoomData:roomData];
    }
}

- (void)setView:(id<PLVECChatroomViewProtocol>)view {
    _view = view;
    if ([view respondsToSelector:@selector(presenter)]) {
        view.presenter = self;
    }
    if ([view respondsToSelector:@selector(tableView)]) {
        view.tableView.delegate = self;
        view.tableView.dataSource = self;
    }
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [[PLVChatroomViewMode alloc] init];
        self.socketManager = [[PLVSocketManager alloc] init];
        [self.socketManager addObserver:self];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:ChatroomRefreshFrequency target:self selector:@selector(pollingQueueTimer) userInfo:nil repeats:YES];
        self.likeTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(pollingLikeCountTimer) userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark - External API

- (void)loadHistoryDataWithCount:(NSInteger)count {
    if (self.loadingHistory) {
        return;
    }
    self.loadingHistory = YES;
    
    __weak typeof(self) weakSelf = self;
    NSUInteger roomId = [self.roomData.roomId longLongValue];
    NSInteger startIndex = self.viewModel.dataSource.count;
    NSInteger endIndex = startIndex + count - 1;
    [PLVLiveVideoAPI requestChatRoomHistoryWithRoomId:roomId startIndex:startIndex endIndex:endIndex completion:^(NSArray * _Nonnull historyList) {
        weakSelf.loadingHistory = NO;
        BOOL success = (historyList && [historyList isKindOfClass:[NSArray class]]);
        if (success) {
            for (NSDictionary *dict in historyList) {
                PLVChatCellModel *model = [weakSelf modelWithHistoryMessageDict:dict];
                if (model && [model isKindOfClass:[PLVChatCellModel class]]) {
                    [weakSelf.viewModel insertModel:model atIndex:0];
                }
            }
            weakSelf.noMoreHistory = [historyList count] < count;
            if (weakSelf.view &&
                [weakSelf.view respondsToSelector:@selector(loadHistoryDataSuccessAtFirstTime:hasNoMoreMessage:)]) {
                [weakSelf.view loadHistoryDataSuccessAtFirstTime:(startIndex == 0) hasNoMoreMessage:weakSelf.noMoreHistory];
            }
        } else {
            if (weakSelf.view && [weakSelf.view respondsToSelector:@selector(loadHistoryDataFailure)]) {
                [weakSelf.view loadHistoryDataFailure];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        weakSelf.loadingHistory = NO;//
        if (weakSelf.view && [weakSelf.view respondsToSelector:@selector(loadHistoryDataFailure)]) {
            [weakSelf.view loadHistoryDataFailure];
        }
    }];
}

- (BOOL)speakMessage:(NSString *)message {
    PLVLiveWatchUser *watchUser = self.roomData.watchUser;
    PLVChatTextModel *textModel = [PLVChatTextModel textModelWithNickName:watchUser.nickName content:message];
    PLVChatCellModel *cellModel = [[self.speakChatCellModelClass alloc] init];
    if ([cellModel isKindOfClass:PLVChatCellModel.class]) {
        [cellModel reloadModelWithChatModel:textModel];
        [self.viewModel addModel:cellModel toCache:NO];
        
        [self reloadData];
    }
    
    return [self p_emitSpeakMessage:message];
}

- (void)likeAction {
    self.likeCountOfMe ++;
    self.roomData.likeCount ++;
}

- (void)destroy {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.likeTimer) {
        [self.likeTimer invalidate];
        self.likeTimer = nil;
    }
}

#pragma mark - Internal API

#pragma mark 子类需重写的方法

- (Class)speakChatCellClass {
    return PLVChatBaseCell.class;
}

- (Class)speakChatCellModelClass {
    return PLVChatCellModel.class;
}

- (Class)imageChatCellClass {
    return PLVChatBaseCell.class;
}

- (Class)imageChatCellModelClass {
    return PLVChatCellModel.class;
}

#pragma mark Socket Event

/// 有用户登陆事件
- (void)loginEvent:(NSDictionary *)data {
    self.roomData.onlineCount = PLV_SafeIntegerForDictKey(data, @"onlineUserNumber");
    
    NSDictionary *user = PLV_SafeDictionaryForDictKey(data, @"user");
    NSString *userId = PLV_SafeStringForDictKey(user, @"userId");;
    NSString *userIdForWatchUser = self.roomData.userIdForWatchUser;
    BOOL me = [userId isEqualToString:userIdForWatchUser];
    [self.viewModel enqueueLoginUser:user me:me];
    if (!me) {
        self.roomData.watchViewCount ++; // 观看热度加一
    }
}

/// 有用户登出事件
- (void)logoutEvent:(NSDictionary *)data {
    self.roomData.onlineCount = PLV_SafeIntegerForDictKey(data, @"onlineUserNumber");
}

/// 公告事件
- (void)bulletinEvent:(NSDictionary *)data {
    
}

/// 用户设置昵称事件
- (void)setNickEvent:(NSDictionary *)data {

}

/// 收到发言消息事件
- (void)speakMessageEvent:(NSDictionary *)data {
    NSString *userIdForWatchUser = self.roomData.userIdForWatchUser;
    NSDictionary *user = PLV_SafeDictionaryForDictKey(data, @"user");
    NSString *status = PLV_SafeStringForDictKey(data, @"status");
    if (status) {  // 单播消息
        if ([status isEqualToString:@"censor"]) { // 聊天审核
        } else if ([status isEqualToString:@"error"]) { // 严禁词
            NSLog(@"%@", PLV_SafeStringForDictKey(data, @"message")); // 严禁词提示
        }
    } else if ([user isKindOfClass:NSDictionary.class]) { // 用户发言
        if ([userIdForWatchUser isEqualToString:PLV_SafeStringForDictKey(user, @"userId")]) {
            // 过滤掉自己的消息（开启聊天室审核后，服务器会广播所有审核后的消息，包含自己发送的消息）
            return;
        }
        
        NSArray *values = PLV_SafeArraryForDictKey(data, @"values");
        PLVChatTextModel *textModel = [PLVChatTextModel textModelWithUser:user content:values.firstObject];
        PLVChatCellModel *cellModel = [[self.speakChatCellModelClass alloc] init];
        if ([cellModel isKindOfClass:PLVChatCellModel.class]) {
            [cellModel reloadModelWithChatModel:textModel];
            [self.viewModel addModel:cellModel toCache:YES];
        }
    }
}

/// 收到图片消息事件
- (void)imageMessageEvent:(NSDictionary *)data {
    NSString *userIdForWatchUser = self.roomData.userIdForWatchUser;
    NSDictionary *user = PLV_SafeDictionaryForDictKey(data, @"user");
    NSArray *values = PLV_SafeArraryForDictKey(data, @"values");
    if (!user || !values) {
        return;
    }

    if (![userIdForWatchUser isEqualToString:PLV_SafeStringForDictKey(user, @"userId")]) {
        NSDictionary *content = PLV_SafeDictionaryForValue(values.firstObject);
        PLVChatImageModel *imageModel = [PLVChatImageModel imageModelWithUser:user imageUrl:PLV_SafeStringForDictKey(content, @"uploadImgUrl") imageId:PLV_SafeStringForDictKey(content, @"id") size:PLV_SafeDictionaryForDictKey(content, @"size")];
        PLVChatCellModel *cellModel = [[self.imageChatCellModelClass alloc] init];
        if ([cellModel isKindOfClass:PLVChatCellModel.class]) {
            [cellModel reloadModelWithChatModel:imageModel];
            [self.viewModel addModel:cellModel toCache:YES];
        }
    }
}

/// 关闭或打开聊天室事件
- (void)closeChatroomEvent:(NSDictionary *)data {
    NSDictionary *value = PLV_SafeDictionaryForDictKey(data, @"value");
    BOOL closed = PLV_SafeBoolForDictKey(value, @"closed");
    self.viewModel.closed = closed;
}

/// 删除一条消息事件
- (void)removeContentEvent:(NSDictionary *)data {
    
}

/// 清空所有消息事件
- (void)removeHistoryEvent {
    [self.viewModel removeAllModels];
}

/// 禁言事件
- (void)addShieldEvent:(NSDictionary *)data {
    
}

/// 解禁言事件
- (void)removeShieldEvent:(NSDictionary *)data {
    
}

/// 踢人事件
- (void)kickEvent:(NSDictionary *)data {
    
}

/// 点赞事件
- (void)likesEvent:(NSDictionary *)data {
    
}

/// 送花事件
- (void)flowersEvent:(NSDictionary *)data {
    
}

/// 打赏事件
- (void)rewardEvent:(NSDictionary *)data {
    
}

/// 讲师回答事件
- (void)teacherAnswerEvent:(NSDictionary *)data {
    
}

/// 学生提问事件
- (void)studentQuestionEvent:(NSDictionary *)data {
    
}

#pragma mark View Event

- (void)reloadData {
    [self.view.tableView reloadData];
    [self.view scrollsToBottom:YES];
}

#pragma mark 欢迎语逻辑

- (void)dequeueWelcomeMessage {
    if (self.viewModel.loginUserOfMe) {
        [self showWelcomeMessage:PLV_SafeStringForDictKey(self.viewModel.loginUserOfMe, @"nick")];
        self.viewModel.loginUserOfMe = nil;
    } else if ((int)(self.timing/ChatroomRefreshFrequency) % 2 == 0) { // 1s
        NSUInteger count = self.viewModel.loginUserCacheQueue.count;
        if (count >= 10) {
            [self popWelcomeMessage:YES];
        } else if (count > 0) {
            [self popWelcomeMessage:NO];
        }
    }
}

- (void)popWelcomeMessage:(BOOL)all {
    NSDictionary *loginUser = [self.viewModel.loginUserCacheQueue lastObject];
    [self.viewModel.loginUserCacheQueue removeLastObject];
    NSString *nickNames = PLV_SafeStringForDictKey(loginUser, @"nick");
    if (all) {
        for (NSInteger i = 0; i < 2; i++) {
            loginUser = self.viewModel.loginUserCacheQueue[i];
            nickNames = [nickNames stringByAppendingString:[NSString stringWithFormat:@"、%@", PLV_SafeStringForDictKey(loginUser, @"nick")]];
        }
        nickNames = [nickNames stringByAppendingString:[NSString stringWithFormat:@"等%d人", (int)self.viewModel.loginUserCacheQueue.count + 1]];
        [self.viewModel.loginUserCacheQueue removeAllObjects];
    }
    [self showWelcomeMessage:nickNames];
}

- (void)showWelcomeMessage:(NSString *)nickNames {
    NSString *welcomeMessage = [NSString stringWithFormat:@"欢迎 %@ 进入直播间",nickNames];
    [self.view showWelcomeView:welcomeMessage duration:4.0];
}

#pragma mark - Private

- (PLVChatCellModel *)modelWithHistoryMessageDict:(NSDictionary *)messageDict {
    PLVChatCellModel *model = nil;
    
    NSString *msgType = PLV_SafeStringForDictKey(messageDict, @"msgType");
    NSString *msgSource = PLV_SafeStringForDictKey(messageDict, @"msgSource");
    NSString *msgId = PLV_SafeStringForDictKey(messageDict, @"id");
    NSDictionary *user = PLV_SafeDictionaryForDictKey(messageDict, @"user");
    NSString *uid = PLV_SafeStringForDictKey(user, @"uid");
    
    if (msgSource && [msgSource isEqualToString:@"chatImg"]) { // 图片消息
        NSDictionary *contentDict = PLV_SafeDictionaryForDictKey(messageDict, @"content");
        NSDictionary *size = PLV_SafeDictionaryForDictKey(contentDict, @"size");
        NSString *uploadImgUrl = PLV_SafeStringForDictKey(contentDict, @"uploadImgUrl");
        NSString *imgId = PLV_SafeStringForDictKey(contentDict, @"id");
        PLVChatImageModel *imageModel = [PLVChatImageModel imageModelWithUser:user imageUrl:uploadImgUrl imageId:imgId size:size];
        imageModel.msgId = msgId;
        PLVChatCellModel *cellModel = [[self.imageChatCellModelClass alloc] init];
        if ([cellModel isKindOfClass:PLVChatCellModel.class]) {
            [cellModel reloadModelWithChatModel:imageModel];
        }
        model = cellModel;
    } else if (!msgType && !msgSource && ![uid isEqualToString:@"1"] && ![uid isEqualToString:@"2"]) { // 文本消息
        NSString *content = PLV_SafeStringForDictKey(messageDict, @"content");
        if (content) {
            PLVChatTextModel *textModel = [PLVChatTextModel textModelWithUser:user content:content];
            textModel.msgId = msgId;
            PLVChatCellModel *cellModel = [[self.speakChatCellModelClass alloc] init];
            if ([cellModel isKindOfClass:PLVChatCellModel.class]) {
                [cellModel reloadModelWithChatModel:textModel];
            }
            model = cellModel;
        }
    }
    
    return model;
}

#pragma mark Emit socket message

- (BOOL)p_emitSpeakMessage:(NSString *)content {
    if (!self.roomData || !self.socketManager) {
        NSLog(@"[PLVChatroomPresenter Error] channel、roomData or socketManager be nil！");
        return NO;
    }
    if (![content isKindOfClass:NSString.class]) {
        NSLog(@"[PLVChatroomPresenter Error] content 参数不合法！");
        return NO;
    }
    
    NSMutableDictionary *speakDict = [NSMutableDictionary dictionary];
    plv_dict_set(speakDict, @"EVENT", @"SPEAK");
    plv_dict_set(speakDict, @"values", @[content]);
    plv_dict_set(speakDict, @"roomId", self.roomData.roomId);
    plv_dict_set(speakDict, @"channelId", self.roomData.channelId);
    plv_dict_set(speakDict, @"sessionId", self.roomData.sessionId);
    plv_dict_set(speakDict, @"accountId", self.roomData.userIdForAccount);
    
    [self.socketManager emitMessage:speakDict];
    
    return YES;
}

- (void)p_emitImageMessage:(NSDictionary *)content {
    
}

- (BOOL)p_emitLikeMessage:(NSUInteger)likeCount {
    if (!self.roomData || !self.socketManager) {
        NSLog(@"[PLVChatroomPresenter Error] channel、roomData or socketManager be nil！");
        return NO;
    }
    
    PLVLiveWatchUser *watchUser = self.roomData.watchUser;
    
    NSMutableDictionary *likeDict = [NSMutableDictionary dictionary];
    plv_dict_set(likeDict, @"EVENT", @"LIKES");
    plv_dict_set(likeDict, @"count", @(likeCount));
    plv_dict_set(likeDict, @"roomId", self.roomData.roomId);
    plv_dict_set(likeDict, @"sessionId", self.roomData.sessionId);
    plv_dict_set(likeDict, @"userId", self.roomData.userIdForWatchUser);
    plv_dict_set(likeDict, @"nick", watchUser.nickName);
    
    [self.socketManager emitMessage:likeDict];
    
    return YES;
}

#pragma mark - Timer

#pragma mark 欢迎语、聊天消息

- (void)pollingQueueTimer {
    self.timing ++;
    
    [self dequeueWelcomeMessage];
    BOOL success = [self.viewModel dequeueChatMessage];
    if (success) {
        [self reloadData];
    }
}

#pragma mark 点赞

- (void)pollingLikeCountTimer {
    self.likeTiming ++;
    
    if (self.likeCountOfMe > 0) { //5秒发送一次点赞 Socket（本时间段内的点赞总数）
        if (self.likeCountOfMe > 5) {
            self.likeCountOfMe = 5;
        }
        self.likeCountOfHttp += self.likeCountOfMe;
        [self p_emitLikeMessage:self.likeCountOfMe];
        self.likeCountOfMe = 0;
    }
    if (self.likeCountOfHttp > 0 && self.likeTiming % 6 == 0) { //30秒发送一次点赞http统计（本时间段内的点赞总数）
        if (self.likeCountOfHttp > 30) {
            self.likeCountOfHttp = 30;
        }
        
        NSUInteger currentLikeCountOfHttp = self.likeCountOfHttp;
        __weak typeof(self) weakSelf = self;
        [PLVLiveVideoAPI likeWithChannelId:self.roomData.channelId.integerValue viewerId:self.roomData.userIdForWatchUser times:currentLikeCountOfHttp completion:^{
            weakSelf.likeCountOfHttp -= currentLikeCountOfHttp;
        } failure:^(NSError *error) {
            NSLog(@"like api error: %@", error.localizedDescription);
        }];
    }
}

#pragma mark - <PLVSocketObserverProtocol>

- (void)socketDidReceiveMessage:(NSString *)string jsonDict:(NSDictionary *)jsonDict {
    NSString *subEvent = PLV_SafeStringForDictKey(jsonDict, @"EVENT");
    if ([subEvent isEqualToString:@"LOGIN"]) {   // someone logged in chatroom
        [self loginEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"LOGOUT"]) { // someone logged in chatroom
        [self logoutEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"BULLETIN"]) { //
        [self bulletinEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"SET_NICK"]) { // set nick
        [self setNickEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"SPEAK"]) {  // someone speaks
        [self speakMessageEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"CHAT_IMG"]) { // someone send a picture message
        [self imageMessageEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"CLOSEROOM"]) { // admin closes or opens the chatroom
        [self closeChatroomEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"REMOVE_CONTENT"]) { // admin deleted a message
        [self removeContentEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"REMOVE_HISTORY"]) { // admin emptied the chatroom
        [self removeHistoryEvent];
    } else if ([subEvent isEqualToString:@"ADD_SHIELD"]) { // admin silenced someone
        [self addShieldEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"REMOVE_SHIELD"]) { // admin lifts the ban on someone
        [self removeShieldEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"REMOVE_SHIELD"]) {
        [self kickEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"LIKES"]) {
        [self likesEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"FLOWERS"]) {
        [self flowersEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"REWARD"]) {
        [self rewardEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"T_ANSWER"]) {
        [self teacherAnswerEvent:jsonDict];
    } else if ([subEvent isEqualToString:@"S_QUESTION"]) {
        [self studentQuestionEvent:jsonDict];
    }
}

- (void)socketLocalError:(NSError *)error {
    NSLog(@"%@ %@",NSStringFromSelector(_cmd),error.localizedDescription);
}

- (void)socketDidStatusChange:(PLVSocketState)state string:(NSString *)string {
    NSLog(@"%@ status %ld %@", NSStringFromSelector(_cmd),state,string);
}

#pragma mark - <PLVSocketServiceProtocol>

- (void)loginSocketServer {
    [self.socketManager loginSocketServer];
}

- (void)reconnect {
    [self.socketManager reconnect];
}

- (void)destroySocket {
    [self.socketManager destroySocket];
}

#pragma mark Observer

- (void)addObserver:(id<PLVSocketObserverProtocol>)observer {
    [self.socketManager addObserver:observer];
}

- (void)removeObserver:(id<PLVSocketObserverProtocol>)observer {
    [self.socketManager removeObserver:observer];
}

#pragma mark Emit message event

- (void)emitMessage:(id)content {
    [self.socketManager emitMessage:content];
}

- (void)emitMessage:(id)content timeout:(double)timeout callback:(void (^)(NSArray *ackArray))callback {
    [self.socketManager emitMessage:content timeout:timeout callback:callback];
}

#pragma mark Emit customMessage event

- (void)emitCustomEvent:(NSString *)event emitMode:(int)emitMode data:(NSDictionary *)data tip:(NSString *)tip {
    [self.socketManager emitCustomEvent:event emitMode:emitMode data:data tip:tip];
}

- (void)emitCustomEvent:(NSString *)event emitMode:(int)emitMode data:(NSDictionary *)data tip:(NSString *)tip timeout:(double)timeout callback:(void (^)(NSArray *ackArray))callback {
    [self.socketManager emitCustomEvent:event emitMode:emitMode data:data tip:tip timeout:timeout callback:callback];
}

#pragma mark Emit else event

- (void)emitMessage:(NSString *)event content:(id)content {
    [self.socketManager emitMessage:event content:content];
}

- (void)emitMessage:(NSString *)event content:(id)content timeout:(double)timeout callback:(void (^)(NSArray *ackArray))callback {
    [self.socketManager emitMessage:event content:content timeout:timeout callback:callback];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *(^defaultCell)(void) = ^(void) {
        NSString *reuseIdentifier = @"reuseIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
        return cell;
    };
    
    if (indexPath.row >= self.viewModel.dataSource.count) {
        return defaultCell();
    }
    
    PLVChatCellModel *model = self.viewModel.dataSource[indexPath.row];
    
    Class chatCellClass;
    if ([model isKindOfClass:self.speakChatCellModelClass]) {
        chatCellClass = self.speakChatCellClass;
    } else if ([model isKindOfClass:self.imageChatCellModelClass]) {
        chatCellClass = self.imageChatCellClass;
    } else {
        return defaultCell();
    }
    
    PLVChatBaseCell *cell;
    if ([chatCellClass isSubclassOfClass:PLVChatBaseCell.class]) {
        NSString *identifier = [chatCellClass identifier];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[chatCellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        [cell setModel:model];
    }
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.viewModel.dataSource.count) {
        return 0.0;
    }
    
    PLVChatCellModel *model = self.viewModel.dataSource[indexPath.row];
    if (model.cellHeight <= 0) {
        model.cellWidth = CGRectGetWidth(tableView.bounds);
        Class chatCellClass;
        if ([model isKindOfClass:self.speakChatCellModelClass]) {
            chatCellClass = self.speakChatCellClass;
        } else if ([model isKindOfClass:self.imageChatCellModelClass]) {
            chatCellClass = self.imageChatCellClass;
        }
        if ([chatCellClass respondsToSelector:@selector(cellHeightWithModel:)]) {
            model.cellHeight = [chatCellClass cellHeightWithModel:model];
        }
    }
    
    return model.cellHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:PLVChatBaseCell.class]) {
        [(PLVChatBaseCell *)cell layoutCell];
    }
}

@end
