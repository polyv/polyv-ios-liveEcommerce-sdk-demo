//
//  PLVChatCellModel.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/16.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVChatMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@class PLVChatBaseCell, UITableView;

@interface PLVChatCellModel : NSObject

@property (nonatomic, strong) PLVChatMessageModel *chatModel;

@property (nonatomic, weak) PLVChatBaseCell *cell;

@property (nonatomic, assign) float cellHeight;

@property (nonatomic, assign) float cellWidth;

@property (nonatomic, assign) BOOL localMessage;  // default NO

@property (nonatomic, assign) BOOL emitSuccess;   // default YES

/// 子类重写方法
- (void)reloadModelWithChatModel:(PLVChatMessageModel *)chatModel;

/// 使用CELL模型数据生成一个CELL
- (PLVChatBaseCell *)makeCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
