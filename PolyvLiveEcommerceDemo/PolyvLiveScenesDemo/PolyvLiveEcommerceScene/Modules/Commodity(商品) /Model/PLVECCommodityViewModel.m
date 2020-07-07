//
//  PLVECCommodityViewModel.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/29.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECCommodityViewModel.h"
#import <UIKit/UIKit.h>

@implementation PLVECCommodityViewModel

- (NSAttributedString *)titleAttrStr {
    if (self.totalItems < 0) {
        self.totalItems = 0;
    }
    UIFont *font = [UIFont systemFontOfSize:12.0];
    NSMutableAttributedString *mAttriStr = [[NSMutableAttributedString alloc] initWithString:@"共件商品" attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:UIColor.whiteColor}];
    NSAttributedString *countStr = [[NSAttributedString alloc] initWithString:@(self.totalItems).stringValue attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor colorWithRed:1 green:153/255.0 blue:17/255.0 alpha:1]}];
    [mAttriStr insertAttributedString:countStr atIndex:1];
    return mAttriStr;
}

@end
