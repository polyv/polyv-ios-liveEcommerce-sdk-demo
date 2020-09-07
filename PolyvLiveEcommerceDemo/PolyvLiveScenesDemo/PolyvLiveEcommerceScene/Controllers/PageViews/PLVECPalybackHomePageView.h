//
//  PLVECPalybackHomePageView.h
//  PolyvLiveEcommerceDemo
//
//  Created by ftao on 2020/5/21.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVECPalybackHomePageView;
@protocol PLVPalybackHomePageViewDelegate <NSObject>

@optional

- (void)homePageView:(PLVECPalybackHomePageView *)homePageView switchPause:(BOOL)pause;

- (void)homePageView:(PLVECPalybackHomePageView *)homePageView seekToTime:(NSTimeInterval)time;

- (void)homePageView:(PLVECPalybackHomePageView *)homePageView switchSpeed:(CGFloat)speed;

@end

/// 直播回放首页视图容器
@interface PLVECPalybackHomePageView : UIView

@property (nonatomic, weak) id<PLVPalybackHomePageViewDelegate> delegate;

- (void)updateChannelInfo:(NSString *)publisher coverImage:(NSString *)coverImage;

- (void)updateWatchViewCount:(NSUInteger)watchViewCount;

- (void)updateVideoDuration:(NSTimeInterval)duration;

- (void)updatePlayButtonState:(BOOL)playing;

- (void)updateDowloadProgress:(CGFloat)dowloadProgress playedProgress:(CGFloat)playedProgress currentPlaybackTime:(NSString *)currentPlaybackTime duration:(NSString *)duration;

@end

NS_ASSUME_NONNULL_END
