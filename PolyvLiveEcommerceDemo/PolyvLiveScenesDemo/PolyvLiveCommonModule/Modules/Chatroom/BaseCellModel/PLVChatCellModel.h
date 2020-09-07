//
//  PLVChatCellModel.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/16.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVChatModel.h"

NS_ASSUME_NONNULL_BEGIN

@class PLVChatCell, UITableView;

@interface PLVChatCellModel : NSObject

@property (nonatomic, strong) PLVChatModel *chatModel;

@property (nonatomic, weak) PLVChatCell *cell;

@property (nonatomic, assign) float cellHeight;

@property (nonatomic, assign) float cellWidth;

@property (nonatomic, assign) BOOL localMessage;  // default NO

@property (nonatomic, assign) BOOL emitSuccess;   // default YES

/// 子类重写方法
- (void)reloadModelWithChatModel:(PLVChatModel *)chatModel;

/// 使用CELL模型数据生成一个CELL
- (PLVChatCell *)makeCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
