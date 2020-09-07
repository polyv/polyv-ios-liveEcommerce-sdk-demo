//
//  PLVChatCell.h
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/16.
//  Copyright © 2020 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVChatCell;
@protocol PLVBaseCellDelegate <NSObject>

@optional
- (void)cellCallback:(PLVChatCell *)cell;

@end

@class PLVChatCellModel;

@interface PLVChatCell : UITableViewCell

@property (class, nonatomic, readonly) NSString *identifier;

@property (nonatomic, strong) PLVChatCellModel *model;

@property (nonatomic, weak) id<PLVBaseCellDelegate> delegate;

#pragma mark 子类重写

- (void)layoutCell;

+ (CGFloat)cellHeightWithModel:(PLVChatCellModel *)model;

@end

NS_ASSUME_NONNULL_END
