//
//  PLVECCommodityViewModel.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/29.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVECCommodityModel.h"

@interface PLVECCommodityViewModel : NSObject

/// 商品模型
@property (nonatomic, copy) NSArray<PLVECCommodityModel *> *models;

/// 总记录数
@property (nonatomic, assign) NSInteger totalItems;

/// 格式化标题字符串
@property (nonatomic, copy) NSAttributedString *titleAttrStr;

@end

