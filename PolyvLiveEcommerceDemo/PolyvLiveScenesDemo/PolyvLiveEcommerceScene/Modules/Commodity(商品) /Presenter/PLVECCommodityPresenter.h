//
//  PLVECCommodityPresenter.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/29.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PLVLiveChannel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVECCommodityPresenterProtocol <NSObject>

@property (nonatomic, strong) PLVLiveChannel *channel;

- (void)loadCommodityInfo;

- (void)clearCommodityInfo;

- (void)receiveProductMessage:(NSInteger)status content:(id)content;

@end

@protocol PLVECCommodityViewProtocol <NSObject>

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

- (void)setupUIOfNoGoods:(BOOL)noGoods;

@end

@interface PLVECCommodityPresenter : NSObject <PLVECCommodityPresenterProtocol>

@property (nonatomic, weak) id<PLVECCommodityViewProtocol> view;

@end

NS_ASSUME_NONNULL_END
