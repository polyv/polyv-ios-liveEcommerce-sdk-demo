//
//  PLVCellModel.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/16.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVBaseCell, UITableView;

@interface PLVCellModel : NSObject

@property (nonatomic, weak) PLVBaseCell *cell;

@property (nonatomic, assign) float cellHeight;

@property (nonatomic, assign) float cellWidth;

@property (nonatomic, assign) BOOL localMessage;  // default NO

@property (nonatomic, assign) BOOL emitSuccess;   // default YES

/// 使用CELL模型数据生成一个CELL
- (PLVBaseCell *)makeCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
