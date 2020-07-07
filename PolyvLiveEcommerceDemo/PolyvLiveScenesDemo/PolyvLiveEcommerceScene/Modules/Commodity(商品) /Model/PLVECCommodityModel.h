//
//  PLVECCommodityModel.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/29.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVECCommodityModel : NSObject

/// 商品主键
@property (nonatomic, assign, readonly) NSInteger productId;

/// 商品名称
@property (nonatomic, copy, readonly) NSString *name;

/// 原价格
@property (nonatomic, assign, readonly) float price;

/// 实际价格
@property (nonatomic, assign, readonly) float realPrice;

/// 封面图片地址
@property (nonatomic, copy, readonly) NSString *cover;

/// 商品链接
@property (nonatomic, copy, readonly) NSString *link;

/// 状态：1上架，2下架
@property (nonatomic, assign, readonly) NSInteger status;

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
