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

@interface PLVSocketManager () <PLVSocketListenerProtocol>

@property (nonatomic, strong) PLVSocket *socket;

@property (nonatomic, strong) NSPointerArray *observers;

@end

@implementation PLVSocketManager
@synthesize listenEvents;

#pragma mark - Public

- (void)loginSocketServer {
    [self p_loginSocketServer];
}

- (void)reconnect {
    [self.socket reconnect];
}

- (void)destroy {
    [self.socket clear];
    [self removeAllObservers];
    self.socket = nil;
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
            //[self exportErrorInfo:[NSString stringWithFormat:@"%@, event 不超过20个字符！",NSStringFromSelector(_cmd)]];
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
            //[self exportErrorInfo:[NSString stringWithFormat:@"%@, data 参数错误！",NSStringFromSelector(_cmd)]];
        }
    }else {
        //[self exportErrorInfo:[NSString stringWithFormat:@"%@, event 参数错误！",NSStringFromSelector(_cmd)]];
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

- (void)p_loginSocketServer {
    if (!self.roomData) {
        NSLog(@"[PLVSocketManager Error] channel、roomData be nil！");
        return;
    }
    if (self.socket) {
        return;
    }
    
    static BOOL loading;
    if (loading) {
        return;
    }
    loading = YES;
    
    __weak typeof(self) weakSelf = self;
    [PLVLiveVideoAPI getChatTokenWithChannelId:self.roomData.channelId.integerValue userId:self.roomData.userIdForWatchUser completion:^(NSDictionary * data, NSError * error) {
        if (error || ![data isKindOfClass:NSDictionary.class]) {
            NSLog(@"聊天室Token获取失败！ %@",error.localizedDescription);
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
    if (self.socket.status == PLVSocketStatusConnected) {
        [self.socket disconnect];
    }
    
    self.socket = [[PLVSocket alloc] init];
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

#pragma mark - <PLVSocketListenerProtocol>

- (void)socket:(PLVSocket *)socket didStatusChange:(PLVSocketStatus)status string:(NSString *)string {
    if (!self.roomData) {
        return;
    }
    if (socket.status != PLVSocketStatusConnected) {
           return;
    }
       
    [socket setSocketLoginStatus:PLVSocketStatusLogining string:nil];
    
    PLVLiveWatchUser *watchUser = self.roomData.watchUser;
    if (!watchUser) {
        return;
    }
    
    // 登录对象
    NSMutableDictionary *loginUser = [NSMutableDictionary dictionary];
    loginUser[@"EVENT"]  = @"LOGIN";
    loginUser[@"roomId"] = self.roomData.roomId;
    loginUser[@"micId"] = self.roomData.roomId;
    loginUser[@"values"] = @[watchUser.nickName, watchUser.avatarUrl, watchUser.userId];
    loginUser[@"type"]   = @"student";
    if (self.roomData.userIdForAccount) {
        loginUser[@"accountId"] = self.roomData.userIdForAccount;
    }
    loginUser[@"channelId"] = self.roomData.channelId;
    
    //__weak typeof(self)weakSelf = self;
    [socket emitMessage:@"message" content:loginUser timeout:12.0 callback:^(NSArray *ackArray) {
        //PLVS_LOG_DEBUG(PLVSConsoleLogModuleTypeSocket, @"login ackArray: %@",ackArray);
        
        //[weakSelf socketLoginAckParserAndLogReport:ackArray];
        
        NSString *ackStr = nil;
        PLVSocketStatus socketStatus = PLVSocketStatusLoginFailed;
        
        if (ackArray) {
            ackStr = [NSString stringWithFormat:@"%@", ackArray.firstObject];
            if (ackStr && ackStr.length > 4) {
                int status = [[ackStr substringToIndex:1] intValue];
                if (status == 2) {
                    socketStatus = PLVSocketStatusLoginSuccess;
                }
            }
        }
        //[weakSelf setSocketLoginStatus:socketStatus string:ackStr];
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
        if ([observer respondsToSelector:@selector(socket:localError:)]) {
            [observer socketLocalError:error];
        }
    }
}

@end
