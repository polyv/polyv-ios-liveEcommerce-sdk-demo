//
//  PLVECLiveViewController.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/4/30.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVLiveRoomData.h"

/// 直播带货场景直播页
@interface PLVECLiveViewController : UIViewController

/// 初始化当前控制器方法
- (instancetype)initWithLiveRoomData:(PLVLiveRoomData *)roomData;

@end
