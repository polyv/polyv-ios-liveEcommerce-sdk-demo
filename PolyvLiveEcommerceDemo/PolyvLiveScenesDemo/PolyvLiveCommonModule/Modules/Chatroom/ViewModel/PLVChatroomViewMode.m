//
//  PLVChatroomViewMode.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/12.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVChatroomViewMode.h"

@interface PLVChatroomViewMode ()

@property (nonatomic, strong) NSMutableArray<PLVChatCellModel *> *dataSource;
/// 消息缓存队列
@property (nonatomic, strong) NSMutableArray<PLVChatCellModel *> *chatCacheQueue;

@property (nonatomic, strong) NSMutableArray<PLVChatCellModel *> *privateChatDataSource;

@end

@implementation PLVChatroomViewMode {
    dispatch_semaphore_t _dataSourceLock;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataSourceLock = dispatch_semaphore_create(1);
        
        // 初始化数组一个默认大小空间，不影响实际容量
        self.dataSource = [NSMutableArray arrayWithCapacity:500];
        self.maxCount = 10000;
        
        self.chatCacheQueue = [NSMutableArray arrayWithCapacity:100];
        
        self.loginUserCacheQueue = [NSMutableArray arrayWithCapacity:20];
    }
    return self;
}

#pragma mark - dataSource handle

- (void)addModel:(PLVChatCellModel *)model toCache:(BOOL)cache {
    if (model) {
        dispatch_semaphore_wait(_dataSourceLock, DISPATCH_TIME_FOREVER);
        if (cache) {
            [self.chatCacheQueue addObject:model];
        } else {
            [self.dataSource addObject:model];
        }
        dispatch_semaphore_signal(_dataSourceLock);
    }
}

- (void)insertModel:(PLVChatCellModel *)model atIndex:(NSUInteger)index {
    if (model) {
        dispatch_semaphore_wait(_dataSourceLock, DISPATCH_TIME_FOREVER);
        [self.dataSource insertObject:model atIndex:index];
        dispatch_semaphore_signal(_dataSourceLock);
    }
}

- (void)removeModel:(PLVChatCellModel *)model {
    if (model) {
        dispatch_semaphore_wait(_dataSourceLock, DISPATCH_TIME_FOREVER);
        [self.chatCacheQueue removeObject:model];
        [self.dataSource removeObject:model];
        dispatch_semaphore_signal(_dataSourceLock);
    }
}

- (void)removeAllModels {
    dispatch_semaphore_wait(_dataSourceLock, DISPATCH_TIME_FOREVER);
    [self.chatCacheQueue removeAllObjects];
    [self.dataSource removeAllObjects];
    dispatch_semaphore_signal(_dataSourceLock);
}

- (BOOL)dequeueChatMessage {
    if (self.chatCacheQueue.count > 0) {
        dispatch_semaphore_wait(_dataSourceLock, DISPATCH_TIME_FOREVER);
        [self.dataSource addObjectsFromArray:self.chatCacheQueue];
        [self.chatCacheQueue removeAllObjects];
        
        NSInteger len = self.dataSource.count - self.maxCount;
        if (len > 0 && len < self.dataSource.count) {
            [self.dataSource removeObjectsInRange:NSMakeRange(0, len)];
        }
        dispatch_semaphore_signal(_dataSourceLock);
        return YES;
    }
    return NO;
}

#pragma mark - loginUserCacheQueue handle

- (void)enqueueLoginUser:(NSDictionary *)loginUser me:(BOOL)me {
    if ([loginUser isKindOfClass:NSDictionary.class]) {
        if (me) {
            self.loginUserOfMe = loginUser;
        } else {
            [self.loginUserCacheQueue addObject:loginUser];
        }
    }
}

@end
