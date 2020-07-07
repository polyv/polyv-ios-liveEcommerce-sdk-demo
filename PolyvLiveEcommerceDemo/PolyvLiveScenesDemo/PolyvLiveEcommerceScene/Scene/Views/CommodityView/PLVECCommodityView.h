//
//  PLVECCommodityView.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/28.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECBottomView.h"
#import "PLVECCommodityController.h"

NS_ASSUME_NONNULL_BEGIN

/// 商品视图
@interface PLVECCommodityView : PLVECBottomView <PLVECCommodityViewProtocol>

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UIImageView *notAddedImageView;

@property (nonatomic, strong) UILabel *tipLabel;

@end

NS_ASSUME_NONNULL_END
