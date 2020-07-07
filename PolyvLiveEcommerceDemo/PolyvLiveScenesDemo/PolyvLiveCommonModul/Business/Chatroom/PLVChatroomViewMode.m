//
//  PLVChatroomViewMode.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/12.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVChatroomViewMode.h"

@interface PLVChatroomViewMode ()

@property (nonatomic, strong) NSMutableArray<PLVCellModel *> *dataSource;
@property (nonatomic, strong) NSMutableArray<PLVCellModel *> *chatCacheQueue;

@property (nonatomic, assign) NSUInteger refreshFlag;

@end

@implementation PLVChatroomViewMode

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.refreshFlag = 0;
        self.maxCount = 1000;
        self.refreshRate = 0.5;
        
        self.dataSource = [NSMutableArray array];
        self.chatCacheQueue = [NSMutableArray array];
    }
    return self;
}

#pragma mark - data handle

- (void)addModel:(PLVCellModel *)model {
    [self enqueueChatMessage:model];
}

- (void)addModel:(PLVCellModel *)model enqueue:(BOOL)enqueue {
    if (enqueue) {
        [self enqueueChatMessage:model];
    } else {
        [self.dataSource addObject:model];
        self.refreshFlag ++;
    }
}

- (void)updateModel:(PLVCellModel *)model {
    
}

- (void)removeModel:(PLVCellModel *)model {
    if (model) {
        [self.dataSource removeObject:model];
    }
}

- (void)removeAllModels {
    [self.chatCacheQueue removeAllObjects];
    [self.dataSource removeAllObjects];
    self.refreshFlag ++;
}

- (void)insertModel:(PLVCellModel *)model atIndex:(NSUInteger)index {
    if (model) {
        [self.dataSource insertObject:model atIndex:index];
    }
}

#pragma mark - Data queue manager

- (void)enqueueChatMessage:(PLVCellModel *)model {
    if (model) {
        [self.chatCacheQueue addObject:model];
    }
}

- (BOOL)dequeueChatMessage {
    if (self.chatCacheQueue.count > 0) {
        [self.dataSource addObjectsFromArray:self.chatCacheQueue];
        [self.chatCacheQueue removeAllObjects];
        self.refreshFlag ++;
        return YES;
    }
    return NO;
}

@end
