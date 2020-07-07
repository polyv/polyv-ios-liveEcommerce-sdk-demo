//
//  PLVECRewardController.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/29.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECRewardController.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>

#define GIFTMESSAGE @"GiftMessage"

@implementation PLVECRewardController

#pragma mark - Public

- (BOOL)emitGiftMessage:(NSString *)giftName giftType:(NSString *)giftType {
    if (!giftName || !giftType || !self.socketManager) {
        return NO;
    }
    
    PLVLiveWatchUser *watchUser = self.socketManager.roomData.watchUser;
    if (!watchUser) {
        return NO;
    }
    
    NSDictionary *data = @{@"giftName" : giftName,
                           @"giftType" : giftType,
                           @"giftCount" : @"1"};
    NSString *tip = [NSString stringWithFormat:@"%@ 赠送了 %@",watchUser.nickName, giftName];
    [self.socketManager emitCustomEvent:GIFTMESSAGE emitMode:1 data:data tip:tip];
    
    return YES;
}

#pragma mark - <PLVSocketObserverProtocol>

- (void)socketDidReceiveEvent:(NSString *)event jsonDict:(NSDictionary *)jsonDict {
    if (![event isEqualToString:@"customMessage"]) {
        return;
    }
    
    NSString *subEvent = PLV_SafeStringForDictKey(jsonDict, @"EVENT");
    if ([subEvent isEqualToString:GIFTMESSAGE]) {           // 自定义礼物消息
        if ([self.delegate respondsToSelector:@selector(rewardController:didReceiveGiftMessage:)]) {
            [self.delegate rewardController:self didReceiveGiftMessage:jsonDict];
        }
    }
}

@end
