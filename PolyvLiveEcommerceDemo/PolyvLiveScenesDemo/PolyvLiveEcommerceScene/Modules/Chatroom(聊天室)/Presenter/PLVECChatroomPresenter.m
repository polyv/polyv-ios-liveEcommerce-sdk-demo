//
//  PLVECChatroomPresenter.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/13.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECChatroomPresenter.h"
#import "PLVECChatCell.h"
#import "PLVECChatCellModel.h"

@interface PLVECChatroomPresenter ()
/// 是否已加载过历史消息（仅限第一次），默认 NO
@property (nonatomic, assign) BOOL loadedHistory;

@end

@implementation PLVECChatroomPresenter

#pragma mark Public Method

- (void)loadHistoryAtFirstTime {
    if (self.loadedHistory) {
        return;
    }
    self.loadedHistory = YES;
    [self loadHistoryDataWithCount:10];
}

#pragma mark - Override

/// 重写发言消息 Cell 及 CellModel 类型

- (Class)speakChatCellClass {
    return PLVECChatCell.class;
}

- (Class)speakChatCellModelClass {
    return PLVECChatCellModel.class;
}

/// 重写图片消息 Cell 及 CellModel 类型

- (Class)imageChatCellClass {
    return PLVECChatCell.class;
}

- (Class)imageChatCellModelClass {
    return PLVECChatCellModel.class;
}

@end
