//
//  PLVECRewardController.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/29.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVSocketManager.h"

NS_ASSUME_NONNULL_BEGIN

@class PLVECRewardController;
@protocol PLVECRewardControllerProtocol <NSObject>

- (void)rewardController:(PLVECRewardController *)rewardController didReceiveGiftMessage:(NSDictionary *)jsonDict;

@end

@interface PLVECRewardController : NSObject <PLVSocketObserverProtocol>

@property (nonatomic, strong) PLVSocketManager *socketManager;

@property (nonatomic, weak) id<PLVECRewardControllerProtocol> delegate;

- (BOOL)emitGiftMessage:(NSString *)giftName giftType:(NSString *)giftType;

@end

NS_ASSUME_NONNULL_END
