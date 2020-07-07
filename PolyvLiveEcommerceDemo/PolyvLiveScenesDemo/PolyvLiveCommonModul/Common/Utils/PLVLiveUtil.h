//
//  PLVLiveUtil.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/12.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

CGFloat P_TopOfEdgeInsets (void);
CGFloat P_BottomOfEdgeInsets (void);

NS_ASSUME_NONNULL_BEGIN

/// 直播工具类
@interface PLVLiveUtil : NSObject

+ (void)drawViewCornerRadius:(UIView *)view cornerRadii:(CGSize)cornerRadii corners:(UIRectCorner)corners;

+ (void)drawViewCornerRadius:(UIView *)view size:(CGSize)size cornerRadii:(CGSize)cornerRadii corners:(UIRectCorner)corners;

@end

NS_ASSUME_NONNULL_END
