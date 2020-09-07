//
//  PLVECLiveHomePageView.h
//  PolyvLiveEcommerceDemo
//
//  Created by ftao on 2020/5/21.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVECChatroomView.h"
#import "PLVECCommodityView.h"
#import "PLVECLiveRoomInfoView.h"
#import "PLVECMoreView.h"
#import "PLVECSwitchView.h"
#import "PLVECBulletinView.h"
#import "PLVECGiftView.h"
#import "PLVLiveRoomData.h"

NS_ASSUME_NONNULL_BEGIN

@class PLVECLiveHomePageView;
@protocol PLVECLiveHomePageViewDelegate <NSObject>

- (PLVLiveRoomData *)currentLiveRoomData;

@optional

- (void)likeActionInHomePageView:(PLVECLiveHomePageView *)homePageView;

- (void)homePageView:(PLVECLiveHomePageView *)homePageView switchPlayLine:(NSUInteger)line;

- (void)homePageView:(PLVECLiveHomePageView *)homePageView switchAudioMode:(BOOL)audioMode;

- (void)emitCustomEvent:(NSString *)event emitMode:(int)emitMode data:(NSDictionary *)data tip:(NSString *)tip;

- (BOOL)playerIsPlaying;

@end

/// 直播主页视图容器
@interface PLVECLiveHomePageView : UIView

@property (nonatomic, strong) PLVECLiveRoomInfoView *liveRoomInfoView; // 直播详情视图
@property (nonatomic, strong) PLVECChatroomView *chatroomView;         // 聊天室视图
@property (nonatomic, strong) PLVECCommodityView *commodityView;       // 商品视图
@property (nonatomic, strong) PLVECMoreView *moreView;                 // 更多视图
@property (nonatomic, strong) PLVECSwitchView *switchLineView;         // 切换视图
@property (nonatomic, strong) PLVECGiftView *giftView;                 // 礼物视图

@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UILabel *likeLable;

@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *giftButton;
@property (nonatomic, strong) UIButton *shoppingCardButton;

@property (nonatomic, weak) id<PLVECLiveHomePageViewDelegate> delegate;

- (void)updateChannelInfo:(NSString *)publisher coverImage:(NSString *)coverImage;

- (void)updateWatchViewCount:(NSUInteger)watchViewCount;

- (void)updateLikeCount:(NSUInteger)likeCount;

- (void)updateLineCount:(NSUInteger)lineCount;

- (void)updatePlayerState:(BOOL)playing;

- (void)showBulletinView:(NSString *)content;

- (void)showLikeAnimation;

- (void)receiveCustomMessage:(NSDictionary *)jsonDict;

- (void)receiveProductMessage:(NSDictionary *)jsonDict;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
