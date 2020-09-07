//
//  PLVSocketManager.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/15.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVSocketServiceProtocol.h"
#import "PLVLiveRoomData.h"

/// socket 信令管理
@interface PLVSocketManager : NSObject <PLVSocketServiceProtocol>

@property (nonatomic, strong) PLVLiveRoomData *roomData;

@end
