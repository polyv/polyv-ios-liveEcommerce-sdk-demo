//
//  PLVECRewardController.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/29.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECRewardController.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>

@interface PLVECRewardController () <PLVECRewardViewDelegate>

@end

@implementation PLVECRewardController

#pragma mark - Setter

- (void)setView:(PLVECRewardView *)view {
    _view = view;
    if (view) {
        view.delegate = self;
        [view setCloseButtonActionBlock:^(PLVECBottomView * _Nonnull view) {
            [view setHidden:YES];
        }];
    }
}

#pragma mark - Public

//- (void)receiveCustomMessage:(NSDictionary *)jsonDict {
//    NSString *subEvent = PLV_SafeStringForDictKey(jsonDict, @"EVENT");
//    if ([subEvent isEqualToString:GIFTMESSAGE]) {           // 自定义礼物消息
//        NSDictionary *user = PLV_SafeDictionaryForDictKey(jsonDict, @"user");
//        NSDictionary *data = PLV_SafeDictionaryForDictKey(jsonDict, @"data");
//        NSString *userIdForWatchUser = self.channel.watchUser.userId;
//        if ([userIdForWatchUser isEqualToString:PLV_SafeStringForDictKey(user, @"userId")]) {
//            return;
//        }
//
//        NSString *nickName = PLV_SafeStringForDictKey(user, @"nick");
//        NSString *giftName = PLV_SafeStringForDictKey(data, @"giftName");
//        NSString *giftType = PLV_SafeStringForDictKey(data, @"giftType");
//
//        if ([self.delegate respondsToSelector:@selector(showGiftAnimation:giftName:giftType:duration:)]) {
//            [self.delegate showGiftAnimation:nickName giftName:giftName giftType:giftType duration:2.0];
//        }
//    }
//}

- (void)hiddenView:(BOOL)hidden {
    if (_view) {
        _view.hidden = hidden;
    }
}

#pragma mark - <PLVECRewardViewDelegate>

- (void)rewardView:(PLVECRewardView *)rewardView didSelectItem:(PLVECGiftItem *)giftItem {
    [rewardView setHidden:YES];
    
    NSString *giftName = giftItem.name;
    NSString *giftType = [giftItem.imageName substringFromIndex:14];
    
    PLVLiveWatchUser *watchUser = self.channel.watchUser;
    if (!giftName || !giftType || !watchUser) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(showGiftAnimation:giftName:giftType:)]) {
        [self.delegate showGiftAnimation:watchUser.nickName giftName:giftName giftType:giftType];
    }
    
    NSDictionary *data = @{@"giftName" : giftName,
                           @"giftType" : giftType,
                           @"giftCount" : @"1"};
    NSString *tip = [NSString stringWithFormat:@"%@ 赠送了 %@",watchUser.nickName, giftName];
    if ([self.delegate respondsToSelector:@selector(emitCustomEvent:emitMode:data:tip:)]) {
        [self.delegate emitCustomEvent:GIFTMESSAGE emitMode:1 data:data tip:tip];
    }
}

@end
