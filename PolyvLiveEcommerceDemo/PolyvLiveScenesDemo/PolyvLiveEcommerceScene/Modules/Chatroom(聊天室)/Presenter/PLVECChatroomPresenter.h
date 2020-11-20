//
//  PLVECChatroomPresenter.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/13.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVChatroomPresenter.h"

NS_ASSUME_NONNULL_BEGIN

/// 该场景下的聊天室业务类
@interface PLVECChatroomPresenter : PLVChatroomPresenter

/// 用于socket登陆后首次加载历史消息，只允许调用一次
- (void)loadHistoryAtFirstTime;

@end

NS_ASSUME_NONNULL_END
