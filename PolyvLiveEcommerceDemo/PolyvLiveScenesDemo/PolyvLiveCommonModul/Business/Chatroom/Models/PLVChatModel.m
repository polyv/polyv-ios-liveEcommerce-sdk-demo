//
//  PLVChatModel.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/7.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVChatModel.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>
#import <PolyvFoundationSDK/PLVColorUtil.h>

PLVChatUserType PLVChatUserTypeWithString(NSString *userType) {
    if (![userType isKindOfClass:NSString.class]) {
        return PLVChatUserTypeUnknown;
    }
    
    if ([userType isEqualToString:@""]
        || [userType isEqualToString:@"student"]) {
        return PLVChatUserTypeStudent;
    }else if ([userType isEqualToString:@"slice"]) {
        return PLVChatUserTypeSlice;
    }else if ([userType isEqualToString:@"viewer"]) {
        return PLVChatUserTypeViewer;
    }else if ([userType isEqualToString:@"guest"]) {
        return PLVChatUserTypeGuest;
    }else if ([userType isEqualToString:@"teacher"]) {
            return PLVChatUserTypeTeacher;
    }else if ([userType isEqualToString:@"assistant"]) {
        return PLVChatUserTypeAssistant;
    }else if ([userType isEqualToString:@"manager"]) {
        return PLVChatUserTypeManager;
    }else if ([userType isEqualToString:@"dummy"]) {
        return PLVChatUserTypeDummy;
    }else {
        return PLVChatUserTypeUnknown;
    }
}

BOOL IsSpecialIdentityOfUserType(PLVChatUserType userType) {
    switch (userType) {
        case PLVChatUserTypeGuest:
        case PLVChatUserTypeTeacher:
        case PLVChatUserTypeAssistant:
        case PLVChatUserTypeManager:
            return YES;
        default:
            return NO;
    }
}

@interface PLVChatUser ()

@property (nonatomic, strong) NSString *userTypeStr;

@end

@implementation PLVChatUser

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    if (![userInfo isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.userId = PLV_SafeStringForDictKey(userInfo, @"userId");
        self.nickName = PLV_SafeStringForDictKey(userInfo, @"nick");
        self.banned = PLV_SafeBoolForDictKey(userInfo, @"banned");
        
        self.userTypeStr = PLV_SafeStringForDictKey(userInfo, @"userType");
        self.userType = PLVChatUserTypeWithString(self.userTypeStr);
        
        // 自定义参数
        NSDictionary *authorization = userInfo[@"authorization"];
        NSString *actor = PLV_SafeStringForDictKey(userInfo, @"actor");
        if ([authorization isKindOfClass:NSDictionary.class]) {
            self.actor = PLV_SafeStringForDictKey(authorization, @"actor");
            self.actorTextColor = [PLVColorUtil colorFromHexString:authorization[@"fColor"]];
            self.actorBackgroundColor = [PLVColorUtil colorFromHexString:authorization[@"bgColor"]];
        }else if (actor && actor.length) {
            self.actor = actor;
        }
        
        self.avatar = PLV_SafeStringForDictKey(userInfo, @"pic");
        // 处理"//"类型开头的地址为 HTTPS
        // 不处理其他类型头像地址，如 “http://” 开头地址，此地址可能为第三方地址，无法判断是否支持 HTTPS
        if ([self.avatar hasPrefix:@"//"]) {
            self.avatar = [@"https:" stringByAppendingString:self.avatar];
        }
        // URL percent-Encoding，头像地址中含有中文字符问题
        self.avatar = [PLVFdUtil stringBySafeAddingPercentEncoding:self.avatar];
        
        self.specialIdentity = IsSpecialIdentityOfUserType(self.userType);
    }
    return self;
}

@end

@implementation PLVChatModel

@end
