//
//  PLVChatCell.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/16.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVChatCell.h"

@implementation PLVChatCell

+ (NSString *)identifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutCell {
    [self doesNotRecognizeSelector:_cmd];
}

+ (CGFloat)cellHeightWithModel:(PLVChatCellModel *)model {
    return 0.0;
}

@end
