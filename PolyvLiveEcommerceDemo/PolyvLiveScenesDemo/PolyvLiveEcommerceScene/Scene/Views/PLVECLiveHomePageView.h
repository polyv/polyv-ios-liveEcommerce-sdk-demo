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

NS_ASSUME_NONNULL_BEGIN

@class PLVECLiveHomePageView;
@protocol PLVECLiveHomePageViewDelegate <NSObject>

@optional

- (void)likeActionInHomePageView:(PLVECLiveHomePageView *)homePageView;

- (void)homePageView:(PLVECLiveHomePageView *)homePageView switchPlayLine:(NSUInteger)line;

- (void)homePageView:(PLVECLiveHomePageView *)homePageView switchAudioMode:(BOOL)audioMode;

- (void)homePageView:(PLVECLiveHomePageView *)homePageView rewardGift:(NSString *)giftName giftType:(NSString *)giftType;

- (BOOL)playerIsPlaying;

@end

/// 直播主页视图容器
@interface PLVECLiveHomePageView : UIView

@property (nonatomic, weak) id<PLVECLiveHomePageViewDelegate> delegate;

@property (nonatomic, strong) PLVECChatroomView *chatroomView; // 聊天室视图

@property (nonatomic, strong) PLVECCommodityView *commodityView; // 商品视图

- (void)updateChannelInfo:(NSString *)publisher coverImage:(NSString *)coverImage;

- (void)updateWatchViewCount:(NSUInteger)watchViewCount;

- (void)updateLikeCount:(NSUInteger)likeCount;

- (void)updateLineCount:(NSUInteger)lineCount;

- (void)updatePlayerState:(BOOL)playing;

- (void)showBulletinView:(NSString *)content;

- (void)showLikeAnimation;

- (void)showGiftAnimation:(NSString *)userName giftName:(NSString *)giftName giftType:(NSString *)giftType duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
