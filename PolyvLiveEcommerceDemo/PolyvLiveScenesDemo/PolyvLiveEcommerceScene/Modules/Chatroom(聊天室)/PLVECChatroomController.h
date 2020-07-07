//
//  PLVECChatroomController.h
//  PolyvLiveEcommerceDemo
//
//  Created by ftao on 2020/5/26.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVChatroomPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@class PLVECChatroomController, UITableView;

@protocol PLVECChatroomViewProtocol <NSObject>

@property (nonatomic, weak) PLVECChatroomController *chatroomCtrl;

@property (nonatomic, strong) UITableView *tableView;

- (void)scrollsToBottom:(BOOL)animated;

- (void)showWelcomeView:(NSString *)message duration:(NSTimeInterval)duration;

@end

/// 直播带货聊天室
@interface PLVECChatroomController : NSObject <PLVSocketObserverProtocol, PLVChatroomDataProcessorProtocol>

@property (nonatomic, strong, readonly) PLVChatroomPresenter *presenter;

@property (nonatomic, strong) id<PLVECChatroomViewProtocol> chatroomView;

- (void)likeAction;

- (void)speakMessage:(NSString *)message;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
