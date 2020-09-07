//
//  PLVSocketManager.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/15.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVSocketManager.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>
#import <PolyvBusinessSDK/PLVSocket.h>
#import <PolyvBusinessSDK/PolyvBusinessSDK.h>
#import <PolyvCloudClassSDK/PLVLiveVideoAPI.h>

#define SocketManagerErrorDomain @"SocketManagerErrorDomain"

@interface PLVSocketManager () <PLVSocketListenerProtocol>

@property (nonatomic, strong) PLVSocket *socket;

@property (nonatomic, strong) NSPointerArray *observers;

@property (nonatomic, assign) NSUInteger reconnectCount;

@end

@implementation PLVSocketManager
@synthesize listenEvents;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.reconnectCount = 3;
    }
    return self;
}

#pragma mark - <PLVSocketServiceProtocol>

- (void)loginSocketServer {
    [self p_loginSocketServer];
}

- (void)reconnect {
    [self.socket reconnect];
}

- (void)destroySocket {
    [self.socket clear];
    [self removeAllObservers];
    self.socket = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark Observer

- (void)addObserver:(id<PLVSocketObserverProtocol>)observer {
    if (!self.observers) {
        self.observers = [NSPointerArray weakObjectsPointerArray];
    }
    if (![self.observers.allObjects containsObject:observer]
        && [observer conformsToProtocol:@protocol(PLVSocketObserverProtocol)]) {
        [self.observers addPointer:(__bridge void * _Nullable)(observer)];
    }
}

- (void)removeObserver:(id<PLVSocketObserverProtocol>)observer {
    if (observer) {
        NSUInteger index = [self.observers.allObjects indexOfObject:observer];
        [self.observers removePointerAtIndex:index];
    }
}

- (void)removeAllObservers {
    NSUInteger count = self.observers.count;
    for (int i = 0; i < count; i ++) {
        [self.observers removePointerAtIndex:0];
    }
}

#pragma mark Emit message event

- (void)emitMessage:(id)content {
    [self.socket emitMessage:content];
}

- (void)emitMessage:(id)content timeout:(double)timeout callback:(void (^)(NSArray *ackArray))callback {
    [self.socket emitMessage:content timeout:timeout callback:callback];
}

#pragma mark Emit customMessage event

- (void)emitCustomEvent:(NSString *)event emitMode:(int)emitMode data:(NSDictionary *)data tip:(NSString *)tip {
    [self emitCustomEvent:event emitMode:emitMode data:data tip:tip timeout:0 callback:nil];
}

- (void)emitCustomEvent:(NSString *)event emitMode:(int)emitMode data:(NSDictionary *)data tip:(NSString *)tip timeout:(double)timeout callback:(void (^)(NSArray * _Nonnull))callback {
    if (event && event.length) {
        if (event.length > 20) {
            [self exportErrorInfo:-100 descript:[NSString stringWithFormat:@"%@, event 不超过20个字符！",NSStringFromSelector(_cmd)]];
            return;
        }
        if (!tip || ![tip isKindOfClass:[NSString class]] || !tip.length) {
            tip = @"发送了自定义消息";
        }
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithObject:event forKey:@"EVENT"];
            mDict[@"version"] = @(1);
            mDict[@"emitMode"] = @(emitMode);
            mDict[@"roomId"] = self.roomData.roomId;
            mDict[@"data"] = data;
            mDict[@"tip"] = tip;
            if (callback) {
                [self emitMessage:@"customMessage" content:mDict timeout:timeout callback:callback];
            }else {
                [self emitMessage:@"customMessage" content:mDict];
            }
        }else {
            [self exportErrorInfo:-100 descript:[NSString stringWithFormat:@"%@, data 参数错误！",NSStringFromSelector(_cmd)]];
        }
    }else {
        [self exportErrorInfo:-100 descript:[NSString stringWithFormat:@"%@, event 参数错误！",NSStringFromSelector(_cmd)]];
    }
}

#pragma mark Emit else event

- (void)emitMessage:(NSString *)event content:(id)content {
    [self.socket emitMessage:event content:content];
}

- (void)emitMessage:(NSString *)event content:(id)content timeout:(double)timeout callback:(void (^)(NSArray *ackArray))callback {
    [self.socket emitMessage:event content:content timeout:timeout callback:callback];
}

#pragma mark - Private

- (void)exportErrorInfo:(NSUInteger)code descript:(NSString *)descript {
    NSError *error = [NSError errorWithDomain:SocketManagerErrorDomain code:-00 userInfo:@{NSLocalizedDescriptionKey:descript}];
    [self socket:self.socket localError:error];
}

- (void)p_loginSocketServer {
    if (!self.roomData) {
        [self exportErrorInfo:-100 descript:@"channel、roomData be nil！"];
        return;
    }
    
    static BOOL loading;
    if (loading) {
        return;
    }
    loading = YES;
    
    if (self.reconnectCount == 0) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [PLVLiveVideoAPI getChatTokenWithChannelId:self.roomData.channelId.integerValue userId:self.roomData.userIdForWatchUser completion:^(NSDictionary * data, NSError * error) {
        if (error || ![data isKindOfClass:NSDictionary.class]) {
            weakSelf.reconnectCount --;
            [weakSelf exportErrorInfo:-100 descript:[NSString stringWithFormat:@"聊天室Token获取失败！ %@",error.localizedDescription]];
            [self performSelector:@selector(p_loginSocketServer) withObject:nil afterDelay:3.0];
        } else {
            NSString *roomId = weakSelf.roomData.channelId;
            NSString *childRoomEnabled = PLV_SafeStringForDictKey(data, @"childRoomEnabled");
            if (childRoomEnabled && childRoomEnabled.boolValue) {
                NSString *roomIdValue = PLV_SafeStringForDictKey(data, @"roomId");
                if (roomIdValue) {
                    roomId = roomIdValue;
                }
            }
            weakSelf.roomData.roomId = roomId;
            [weakSelf setupSocket:data[@"token"]];
        }
        loading = NO;
    }];
}

- (void)setupSocket:(NSString *)connectToken {
    if (!self.roomData.watchUser) {
        return;
    }
    
    if (self.socket) {
        [self destroySocket];
    }
    
    self.socket = [[PLVSocket alloc] init];
    self.socket.debugMode = PLVLiveSDKConfig.sharedSDK.socketDebug;
    NSString *chatDomain = self.roomData.chatDomain;
    // chat 私有域名
    if (chatDomain && chatDomain.length) {
        if (![chatDomain hasPrefix:@"http"]) {
            chatDomain = [@"https://" stringByAppendingString:chatDomain];
        }
        [self.socket setupConnectToken:connectToken url:chatDomain log:NO];
    } else {
        [self.socket setupConnectToken:connectToken url:nil log:NO];
    }
    
    [self.socket connect];
    
    NSArray *listenEvents = @[@"joinRequest",
                              @"joinResponse",
                              @"joinSuccess",
                              @"joinLeave",
                              @"MuteUserMedia",
                              @"switchView",
                              @"assistantSliceControl",
                              @"customMessage"];
    [self.socket addListenEvents:listenEvents];
    
    [self.socket addListener:self];
}

- (void)setSocketStatusCallback:(PLVSocketState)status string:(NSString *)string {
    for (id<PLVSocketObserverProtocol> observer in self.observers) {
        if ([observer respondsToSelector:@selector(socketDidStatusChange:string:)]) {
            [observer socketDidStatusChange:status string:string];
        }
    }
}

#pragma mark - <PLVSocketListenerProtocol>

- (void)socket:(PLVSocket *)socket didStatusChange:(PLVSocketStatus)status string:(NSString *)string {
    [self setSocketStatusCallback:(PLVSocketState)status string:string];
    
    if (socket.status != PLVSocketStatusConnected) {
       return;
    }
       
    [self setSocketStatusCallback:PLVSocketStateLogining string:nil];
    
    PLVLiveWatchUser *watchUser = self.roomData.watchUser;
    if (!watchUser) {
        return;
    }
    
    // 登录对象
    NSMutableDictionary *loginUser = [NSMutableDictionary dictionary];
    loginUser[@"EVENT"]  = @"LOGIN";
    loginUser[@"roomId"] = self.roomData.roomId;
    loginUser[@"micId"] = self.roomData.roomId;
    if (watchUser.nickName && watchUser.avatarUrl && watchUser.userId) {
        loginUser[@"values"] = @[watchUser.nickName, watchUser.avatarUrl, watchUser.userId];
    }
    loginUser[@"type"]   = watchUser.role;
    if (self.roomData.userIdForAccount) {
        loginUser[@"accountId"] = self.roomData.userIdForAccount;
    }
    loginUser[@"channelId"] = self.roomData.channelId;
    
    __weak typeof(self)weakSelf = self;
    [socket emitMessage:@"message" content:loginUser timeout:12.0 callback:^(NSArray *ackArray) {
        if (PLVLiveSDKConfig.sharedSDK.socketDebug) {
            NSLog(@"login ackArray: %@",ackArray);
        }
        //[weakSelf socketLoginAckParserAndLogReport:ackArray];
        
        NSString *ackStr = nil;
        PLVSocketState socketStatus = PLVSocketStateLoginFailed;
        
        if (ackArray) {
            ackStr = [NSString stringWithFormat:@"%@", ackArray.firstObject];
            if (ackStr && ackStr.length > 4) {
                int status = [[ackStr substringToIndex:1] intValue];
                if (status == 2) {
                    socketStatus = PLVSocketStateLoginSuccess;
                }
            }
        }
        [weakSelf setSocketStatusCallback:socketStatus string:ackStr];
    }];
}

- (void)socket:(PLVSocket *)socket didReceiveMessage:(NSString *)string jsonDict:(NSDictionary *)jsonDict {
    for (id<PLVSocketObserverProtocol> observer in self.observers) {
        if ([observer respondsToSelector:@selector(socketDidReceiveMessage:jsonDict:)]) {
            [observer socketDidReceiveMessage:string jsonDict:jsonDict];
        }
    }
}

- (void)socket:(PLVSocket *)socket didReceiveEvent:(NSString *)event jsonDict:(NSDictionary *)jsonDict {
    for (id<PLVSocketObserverProtocol> observer in self.observers) {
        if ([observer respondsToSelector:@selector(socketDidReceiveEvent:jsonDict:)]) {
            [observer socketDidReceiveEvent:event jsonDict:jsonDict];
        }
    }
}

- (void)socket:(PLVSocket *)socket localError:(NSError *)error {
    for (id<PLVSocketObserverProtocol> observer in self.observers) {
        if ([observer respondsToSelector:@selector(socketLocalError:)]) {
            [observer socketLocalError:error];
        }
    }
}

@end
