//
//  PLVECCommodityCell.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/29.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVECCommodityModel.h"

NS_ASSUME_NONNULL_BEGIN

@class PLVECCommodityCell;
@protocol PLVECCommodityCellDelegate <NSObject>

- (void)commodityCell:(PLVECCommodityCell *)commodityCell didSelectButtonBeClicked:(PLVECCommodityModel *)model;

@end

@interface PLVECCommodityCell : UITableViewCell

@property (nonatomic, strong) UIImageView *coverImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) UIButton *selectButton;

/// 绑定的模型
@property (nonatomic, strong) PLVECCommodityModel *model;

/// 代理人
@property (nonatomic, weak) id<PLVECCommodityCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
