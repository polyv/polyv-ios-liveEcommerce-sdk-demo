//
//  PLVCellModel.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/16.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVCellModel.h"
#import "PLVBaseCell.h"

@implementation PLVCellModel

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
        _cellHeight = [PLVBaseCell cellHeightWithModel:self];
    }
    return _cellHeight;
}

- (PLVBaseCell *)makeCellWithTableView:(UITableView *)tableView {
    PLVBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:PLVBaseCell.identifier];
    if (!cell) {
        cell = [[PLVBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PLVBaseCell.identifier];
    }
    return cell;
}

@end
