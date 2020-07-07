//
//  PLVLiveUtil.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/12.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVLiveUtil.h"

CGFloat P_TopOfEdgeInsets (void) {
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets edgeInsets = UIApplication.sharedApplication.delegate.window.safeAreaInsets;
        return edgeInsets.top;
    } else {
        return 0;
    }
}

CGFloat P_BottomOfEdgeInsets (void) {
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets edgeInsets = UIApplication.sharedApplication.delegate.window.safeAreaInsets;
        return edgeInsets.bottom;
    } else {
        return 0;
    }
}

@implementation PLVLiveUtil

+ (void)drawViewCornerRadius:(UIView *)view cornerRadii:(CGSize)cornerRadii corners:(UIRectCorner)corners {
    [self drawViewCornerRadius:view size:view.bounds.size cornerRadii:cornerRadii corners:corners];
}

+ (void)drawViewCornerRadius:(UIView *)view size:(CGSize)size cornerRadii:(CGSize)cornerRadii corners:(UIRectCorner)corners {
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:corners cornerRadii:cornerRadii];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

@end
