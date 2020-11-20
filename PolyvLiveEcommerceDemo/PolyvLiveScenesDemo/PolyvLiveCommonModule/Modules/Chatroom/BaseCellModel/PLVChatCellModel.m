//
//  PLVChatCellModel.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/16.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVChatCellModel.h"
#import "PLVChatBaseCell.h"

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
        _cellHeight = [PLVChatBaseCell cellHeightWithModel:self];
    }
    return _cellHeight;
}

- (void)reloadModelWithChatModel:(PLVChatMessageModel *)chatModel {
    self.chatModel = chatModel;
}

- (PLVChatBaseCell *)makeCellWithTableView:(UITableView *)tableView {
    PLVChatBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:PLVChatBaseCell.identifier];
    if (!cell) {
        cell = [[PLVChatBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PLVChatBaseCell.identifier];
    }
    return cell;
}

@end
