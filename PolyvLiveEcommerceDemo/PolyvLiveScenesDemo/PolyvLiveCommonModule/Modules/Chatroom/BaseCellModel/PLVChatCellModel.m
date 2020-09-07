//
//  PLVChatCellModel.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/16.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVChatCellModel.h"
#import "PLVChatCell.h"

@implementation PLVChatCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.emitSuccess = YES;
        self.localMessage = NO;
    }
    return self;
}

- (float)cellHeight {
    if (_cellHeight == 0) {
        _cellHeight = [PLVChatCell cellHeightWithModel:self];
    }
    return _cellHeight;
}

- (void)reloadModelWithChatModel:(PLVChatModel *)chatModel {
    self.chatModel = chatModel;
}

- (PLVChatCell *)makeCellWithTableView:(UITableView *)tableView {
    PLVChatCell *cell = [tableView dequeueReusableCellWithIdentifier:PLVChatCell.identifier];
    if (!cell) {
        cell = [[PLVChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PLVChatCell.identifier];
    }
    return cell;
}

@end
