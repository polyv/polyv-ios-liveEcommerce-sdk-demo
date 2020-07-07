//
//  PLVECLiveViewController.h
//  PolyvLiveEcommerceDemo
//
//  Created by Lincal on 2020/4/30.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVLiveRoomData.h"

/// 直播带货场景直播页
@interface PLVECLiveViewController : UIViewController

/// 横屏显示
@property (nonatomic, assign) BOOL landscapeMode;

/// 初始化当前控制器方法
- (instancetype)initWithLiveRoomData:(PLVLiveRoomData *)roomData;

@end
