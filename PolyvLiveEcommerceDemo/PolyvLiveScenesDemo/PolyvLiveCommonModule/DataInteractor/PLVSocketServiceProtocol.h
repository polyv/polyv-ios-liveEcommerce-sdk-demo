//
//  PLVSocketServiceProtocol.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/10.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PLVSocketState) {
    PLVSocketStateNotConnected = 0,
    
    PLVSocketStateDisconnected = 1,
    PLVSocketStateConnecting   = 2,
    PLVSocketStateConnected    = 3,
    PLVSocketStateConnectError = 4,
    
    PLVSocketStateLogining     = 5,
    PLVSocketStateLoginSuccess = 6, /* param string: ack callback*/
    PLVSocketStateLoginFailed  = 7  /* param string: ack callback*/
};

/// 信令监听协议
@protocol PLVSocketObserverProtocol <NSObject>

@optional

/// 回调 "message" 事件
- (void)socketDidReceiveMessage:(NSString *)string jsonDict:(NSDictionary *)jsonDict;

/// 回调除 “message” 事件之外其他事件消息
- (void)socketDidReceiveEvent:(NSString *)event jsonDict:(NSDictionary *)jsonDict;

/// 回调 Socket 状态
- (void)socketDidStatusChange:(PLVSocketState)state string:(NSString *)string;

 /// 回调本地错误信息
- (void)socketLocalError:(NSError *)error;

@end

/// 信令服务协议
@protocol PLVSocketServiceProtocol <NSObject>

/**
 登录socket服务器
*/
- (void)loginSocketServer;

/**
 重连
 */
- (void)reconnect;

/**
 清理释放资源
 */
- (void)destroySocket;

#pragma mark Observer

- (void)addObserver:(id<PLVSocketObserverProtocol>)observer;

- (void)removeObserver:(id<PLVSocketObserverProtocol>)observer;

#pragma mark Emit message event

/**
 提交 "message" 事件消息

 @param content 消息内容，NSString 或 NSDictionary 类型
 */
- (void)emitMessage:(id)content;

/**
 提交带ACK回调的 "message" 事件消息
 
 @param content 消息内容，NSString 或 NSDictionary 类型
 @param timeout ACK 回调超时，默认 0
 @param callback ACK 回调
 */
- (void)emitMessage:(id)content timeout:(double)timeout callback:(void (^)(NSArray *ackArray))callback;

#pragma mark Emit customMessage event

/**
 提交 “customMessage” 事件消息
 
 @param event 自定义消息事件名
 @param emitMode 类型：0 表示广播所有人包括自己，1 表示广播给除了自己的其他人，2 表示只发送给自己
 @param data 自定义消息内容
 @param tip 自定义提示消息，为空时默认为 "发送了自定义消息"
 */
- (void)emitCustomEvent:(NSString *)event emitMode:(int)emitMode data:(NSDictionary *)data tip:(NSString *)tip;

/**
 提交带ACK回调的 “customMessage” 事件消息

 @param event 自定义消息事件名
 @param emitMode 类型：0 表示广播所有人包括自己，1 表示广播给除了自己的其他人，2 表示只发送给自己
 @param data 自定义消息内容
 @param tip 自定义提示消息，为空时默认为 "发送了自定义消息"
 @param timeout 回调超时
 @param callback Ack 回调
 */
- (void)emitCustomEvent:(NSString *)event emitMode:(int)emitMode data:(NSDictionary *)data tip:(NSString *)tip timeout:(double)timeout callback:(void (^)(NSArray *ackArray))callback;

#pragma mark Emit else event

/**
 提交指定事件消息
 
 @param event 事件名
 @param content 消息内容，NSString 或 NSDictionary 类型
 */
- (void)emitMessage:(NSString *)event content:(id)content;

/**
 提交带ACK回调的指定事件消息

 @param event 消息事件，nil时为默认 "message"
 @param content 消息内容，NSString 或 NSDictionary 类型
 @param timeout ACK 回调超时，默认 0
 @param callback ACK 回调
 */
- (void)emitMessage:(NSString *)event content:(id)content timeout:(double)timeout callback:(void (^)(NSArray *ackArray))callback;

@end
