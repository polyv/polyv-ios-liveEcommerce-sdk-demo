//
//  PLVChatImageModel.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/7/7.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVChatModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVChatImageModel : PLVChatModel

/// 图片id
@property (nonatomic, copy) NSString *imageId;

/// 图片大小
@property (nonatomic, assign) NSDictionary *size;

/// 图片地址
@property (nonatomic, copy) NSString *imageUrl;

/// socket image 消息
+ (instancetype)imageModelWithUser:(NSDictionary *)user imageUrl:(NSString *)imageUrl imageId:(NSString *)imageId size:(NSDictionary *)size;

@end

NS_ASSUME_NONNULL_END
