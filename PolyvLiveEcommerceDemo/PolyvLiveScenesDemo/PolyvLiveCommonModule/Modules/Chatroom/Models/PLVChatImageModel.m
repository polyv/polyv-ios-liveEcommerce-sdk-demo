//
//  PLVChatImageModel.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/7.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVChatImageModel.h"

@implementation PLVChatImageModel

+ (instancetype)imageModelWithUser:(NSDictionary *)user imageUrl:(NSString *)imageUrl imageId:(NSString *)imageId size:(NSDictionary *)size {
    if (![user isKindOfClass:NSDictionary.class] || ![imageUrl isKindOfClass:NSString.class]) {
        return nil;
    }
    
    PLVChatImageModel *model = [[self alloc] init];
    if (model) {
        model.user = [[PLVLiveChatUser alloc] initWithUserInfo:user];
        if ([imageUrl hasPrefix:@"http:"]) {
            model.imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
        } else {
            model.imageUrl = imageUrl;
        }
        model.imageId = imageId;
        model.size = size;
    }
    return model;
}

@end
