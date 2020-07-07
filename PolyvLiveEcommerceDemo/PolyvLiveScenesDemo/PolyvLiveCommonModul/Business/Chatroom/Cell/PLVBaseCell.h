//
//  PLVBaseCell.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/16.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVBaseCell;
@protocol PLVBaseCellDelegate <NSObject>

@optional
- (void)cellCallback:(PLVBaseCell *)cell;

@end

@class PLVCellModel;

@interface PLVBaseCell : UITableViewCell

@property (class, nonatomic, readonly) NSString *identifier;

@property (nonatomic, strong) PLVCellModel *model;

@property (nonatomic, weak) id<PLVBaseCellDelegate> delegate;

#pragma mark 子类重写

- (void)layoutCell;

+ (CGFloat)cellHeightWithModel:(PLVCellModel *)model;

@end

NS_ASSUME_NONNULL_END
