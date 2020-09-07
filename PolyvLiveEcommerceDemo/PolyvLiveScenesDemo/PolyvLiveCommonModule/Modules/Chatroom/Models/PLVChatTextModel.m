//
//  PLVChatTextModel.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/7.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVChatTextModel.h"

@implementation PLVChatTextModel

+ (instancetype)textModelWithUser:(NSDictionary *)user content:(NSString *)content {
    if (![user isKindOfClass:NSDictionary.class] || ![content isKindOfClass:NSString.class]) {
        return nil;
    }
    
    PLVChatTextModel *model = [[self alloc] init];
    if (model) {
        model.user = [[PLVLiveChatUser alloc] initWithUserInfo:user];
        model.content = content;
    }
    return model;
}

+ (instancetype)textModelWithNickName:(NSString *)nickName content:(NSString *)content {
    if (![nickName isKindOfClass:NSString.class] || ![content isKindOfClass:NSString.class]) {
        return nil;
    }
    
    PLVChatTextModel *model = [[self alloc] init];
    if (model) {
        PLVLiveChatUser *user = [[PLVLiveChatUser alloc] init];
        user.nickName = nickName;
        user.specialIdentity = NO;
        
        model.user = user;
        model.content = content;
    }
    return model;
}

@end
