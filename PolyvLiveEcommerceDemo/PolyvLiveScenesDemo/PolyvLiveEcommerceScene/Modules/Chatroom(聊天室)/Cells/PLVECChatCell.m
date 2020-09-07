//
//  PLVECChatCell.m
//  PolyvLiveEcommerceDemo
//
//  Created by ftao on 2020/5/27.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECChatCell.h"
#import "PLVECChatCellModel.h"
#import "PLVPhotoBrowser.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>

@interface PLVECChatLabel : UILabel

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@end

@implementation PLVECChatLabel

// 修改绘制文字的区域，edgeInsets增加bounds
-(CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    // 注意传入的UIEdgeInsetsInsetRect(bounds, self.edgeInsets),bounds是真正的绘图区域
    CGRect rect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets) limitedToNumberOfLines:numberOfLines];
    
    rect.origin.x -= self.edgeInsets.left;
    rect.origin.y -= self.edgeInsets.top;
    rect.size.width += self.edgeInsets.left + self.edgeInsets.right;
    rect.size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return rect;
}

- (void)drawTextInRect:(CGRect)rect {
    // 令绘制区域为原始区域，增加的内边距区域不绘制
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

@end

@interface PLVECChatCell ()

@property (nonatomic, strong) PLVECChatLabel *contentLB;

@property (nonatomic, strong) PLVPhotoBrowser *photoBrowser;

@end

@implementation PLVECChatCell

+ (CGFloat)cellHeightWithModel:(PLVChatCellModel *)model {
    if (![model isKindOfClass:PLVECChatCellModel.class]) {
        return 0;
    }
    // TODO: 计算一次，后面不重复计算该值
    PLVECChatCellModel *chatModel = (PLVECChatCellModel *)model;
    CGRect rect = [chatModel.attrCont boundingRectWithSize:CGSizeMake(chatModel.cellWidth-16.0, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                   context:nil];
    // 4+4+4
    return rect.size.height + 12.0;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentLB = [[PLVECChatLabel alloc] init];
        self.contentLB.numberOfLines = 0;
        self.contentLB.edgeInsets = UIEdgeInsetsMake(4, 8, 4, 8);
        self.contentLB.textAlignment = NSTextAlignmentLeft;
        self.contentLB.backgroundColor = [UIColor colorWithWhite:0 alpha:0.39];
        self.contentLB.layer.cornerRadius = 10.0;
        self.contentLB.layer.masksToBounds = YES;
        [self addSubview:self.contentLB];
        
        self.photoBrowser = [[PLVPhotoBrowser alloc] init];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)layoutCell {
    if (![self.model isKindOfClass:PLVECChatCellModel.class]) {
        return;
    }
    
    PLVECChatCellModel *chatModel = (PLVECChatCellModel *)self.model;
    self.contentLB.attributedText = chatModel.attrCont;
    CGSize newSize = [self.contentLB sizeThatFits:CGSizeMake(chatModel.cellWidth, MAXFLOAT)];
    self.contentLB.frame = CGRectMake(0, 0, newSize.width , newSize.height);
}

#pragma mark - Action

- (void)tapGestureAction {
    if (![self.model isKindOfClass:PLVECChatCellModel.class]) {
        return;
    }
    
    if ([[(PLVECChatCellModel *)self.model chatModel] isKindOfClass:PLVChatImageModel.class]) {
        self.userInteractionEnabled = NO;
        PLVChatImageModel *imageModel = (PLVChatImageModel *)[(PLVECChatCellModel *)self.model chatModel];
        UIImageView *imageView = [[UIImageView alloc] init];
        __weak typeof(self)weakSelf = self;
        [PLVFdUtil setImageWithURL:[NSURL URLWithString:imageModel.imageUrl] inImageView:imageView completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
            weakSelf.userInteractionEnabled = YES;
            if (error) {
                NSLog(@"请求失败！%@",error.localizedDescription);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.photoBrowser scaleImageViewToFullScreen:imageView];
                });
            }
        }];
    }
}

@end
