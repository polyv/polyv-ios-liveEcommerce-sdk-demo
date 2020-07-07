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

static inline void plv_dict_set(NSMutableDictionary *mDict, id aKey, id anObject) {
    if (anObject) {
        [mDict setObject:anObject forKey:aKey];
    }
}

@interface PLVChatroomPresenter () <PLVSocketObserverProtocol>

@property (nonatomic, strong) PLVChatroomViewMode *viewModel;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger timing;

@property (nonatomic, strong) NSTimer *likeTimer;
@property (nonatomic, assign) NSUInteger likeTiming;

@property (nonatomic, assign) NSUInteger likeCountOfMe;
@property (nonatomic, assign) NSUInteger likeCountOfHttp;

@property (nonatomic, strong) NSDictionary *loginUserOfMe;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *loginUserCacheQueue;

@end

static const NSTimeInterval ChatroomRefreshFrequency = 0.5;

@implementation PLVChatroomPresenter {
    BOOL _dequeueLoginUserFlag;
    BOOL _dataSourceUpdateFlag;
}

#pragma mark - Setter

- (void)setDataProcessor:(id<PLVChatroomDataProcessorProtocol>)dataProcessor {
    _dataProcessor = dataProcessor;
    _dequeueLoginUserFlag = [dataProcessor respondsToSelector:@selector(presenter:dequeueLoginUser:)];
    _dataSourceUpdateFlag = [dataProcessor respondsToSelector:@selector(presenter:dataSourceUpdate:)];
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dequeueLoginUserFlag = NO;
        _dataSourceUpdateFlag = NO;
        self.loginUserCacheQueue = [NSMutableArray array];
        self.viewModel = [[PLVChatroomViewMode alloc] init];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:ChatroomRefreshFrequency target:self selector:@selector(pollingQueueTimer) userInfo:nil repeats:YES];
        self.likeTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(pollingLikeCountTimer) userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark - Public

- (void)enqueueLoginUser:(NSDictionary *)loginUser me:(BOOL)me {
    if ([loginUser isKindOfClass:NSDictionary.class]) {
        if (me) {
            self.loginUserOfMe = loginUser;
        } else {
            [self.loginUserCacheQueue addObject:loginUser];
        }
    }
}

- (void)reloadData {
    if (_dataSourceUpdateFlag) {
        [self.dataProcessor presenter:self dataSourceUpdate:self.viewModel.dataSource];
    }
}

- (BOOL)emitSpeakMessage:(NSString *)content {
    return [self p_emitSpeakMessage:content];
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

#pragma mark - Emit socket message

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
    if (success && _dataSourceUpdateFlag) {
        [self.dataProcessor presenter:self dataSourceUpdate:self.viewModel.dataSource];
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

#pragma mark - 欢迎语逻辑

- (void)dequeueWelcomeMessage {
    if (self.loginUserOfMe) {
        [self showWelcomeMessage:PLV_SafeStringForDictKey(self.loginUserOfMe, @"nick")];
        self.loginUserOfMe = nil;
    } else if ((int)(self.timing/ChatroomRefreshFrequency) % 3 == 0) {
        NSUInteger count = self.loginUserCacheQueue.count;
        if (count >= 10) {
            [self popWelcomeMessage:YES];
        } else if (count > 0) {
            [self popWelcomeMessage:NO];
        }
    }
}

- (void)popWelcomeMessage:(BOOL)all {
    NSDictionary *loginUser = [self.loginUserCacheQueue lastObject];
    [self.loginUserCacheQueue removeLastObject];
    NSString *nickNames = PLV_SafeStringForDictKey(loginUser, @"nick");
    if (all) {
        for (NSInteger i = 0; i < 2; i++) {
            loginUser = self.loginUserCacheQueue[i];
            nickNames = [nickNames stringByAppendingString:[NSString stringWithFormat:@"、%@", PLV_SafeStringForDictKey(loginUser, @"nick")]];
        }
        nickNames = [nickNames stringByAppendingString:[NSString stringWithFormat:@"等%d人", (int)self.loginUserCacheQueue.count + 1]];
        [self.loginUserCacheQueue removeAllObjects];
    }
    [self showWelcomeMessage:nickNames];
}

- (void)showWelcomeMessage:(NSString *)nickNames {
    if (_dequeueLoginUserFlag) {
        [self.dataProcessor presenter:self dequeueLoginUser:nickNames];
    }
}

@end
