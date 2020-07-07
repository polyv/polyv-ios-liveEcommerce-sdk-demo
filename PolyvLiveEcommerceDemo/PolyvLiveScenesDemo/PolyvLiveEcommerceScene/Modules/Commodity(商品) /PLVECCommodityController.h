//
//  PLVECCommodityController.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/29.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PLVLiveChannel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVECCommodityControllerProtocol <NSObject>

- (void)loadCommodityInfo;

- (void)clearCommodityInfo;

@end

@protocol PLVECCommodityViewProtocol <NSObject>

@property (nonatomic, weak) id<PLVECCommodityControllerProtocol> delegate;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

- (void)setupUIOfNoGoods:(BOOL)noGoods;

@end

@interface PLVECCommodityController : NSObject <PLVECCommodityControllerProtocol>

@property (nonatomic, weak) id<PLVECCommodityViewProtocol> view;

@property (nonatomic, strong) PLVLiveChannel *channel;

@end

NS_ASSUME_NONNULL_END
