//
//  PLVECChatCell.m
//  PolyvLiveEcommerceDemo
//
//  Created by ftao on 2020/5/27.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECChatCell.h"
#import "PLVECChatCellModel.h"
#import "PLVECUtils.h"
#import "PLVPhotoBrowser.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>
#import <SDWebImage/UIImageView+WebCache.h>

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

@property (nonatomic, strong) UIImageView *chatImageView;

@property (nonatomic, strong) UIView *bubbleView;

@property (nonatomic, strong) PLVPhotoBrowser *photoBrowser;

@end

@implementation PLVECChatCell

+ (CGFloat)cellHeightWithModel:(PLVChatCellModel *)model {
    if (![model isKindOfClass:PLVECChatCellModel.class]) {
        return 0;
    }
    // TODO: 计算一次，后面不重复计算该值
    PLVECChatCellModel *cellModel = (PLVECChatCellModel *)model;
    CGRect rect = [cellModel.attrCont boundingRectWithSize:CGSizeMake(cellModel.cellWidth-16.0, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                   context:nil];
    CGFloat cellHeight = 0;
    id chatModel = [(PLVECChatCellModel *)model chatModel];
    if (chatModel && [chatModel isKindOfClass:[PLVChatImageModel class]]) {
        if (cellModel.cellWidth - 16.0 - rect.size.width < 40) {// 图片换行显示
            cellHeight = 4 + rect.size.height + 4 + 36;
        } else { // 图片跟昵称同行显示
            cellHeight = 4 + 36;
        }
    } else {
        cellHeight = 4 + rect.size.height;
    }
    
    return cellHeight + 4 + 4;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bubbleView = [[UIView alloc] init];
        self.bubbleView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.39];
        self.bubbleView.layer.cornerRadius = 10;
        self.bubbleView.layer.masksToBounds = YES;
        [self addSubview:self.bubbleView];
        
        self.contentLB = [[PLVECChatLabel alloc] init];
        self.contentLB.numberOfLines = 0;
        self.contentLB.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.contentLB];
        
        self.chatImageView = [[UIImageView alloc] init];
        self.chatImageView.layer.masksToBounds = YES;
        self.chatImageView.layer.cornerRadius = 4.0;
        self.chatImageView.userInteractionEnabled = YES;
        self.chatImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.chatImageView.hidden = YES;
        [self addSubview:self.chatImageView];
        
        self.photoBrowser = [[PLVPhotoBrowser alloc] init];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [self.chatImageView addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)layoutCell {
    if (![self.model isKindOfClass:PLVECChatCellModel.class]) {
        return;
    }
    
    PLVECChatCellModel *cellModel = (PLVECChatCellModel *)self.model;
    self.contentLB.attributedText = cellModel.attrCont;
    CGSize newSize = [self.contentLB sizeThatFits:CGSizeMake(cellModel.cellWidth - 16, MAXFLOAT)];
    CGFloat contentWidth = 8 + newSize.width + 8;
    CGFloat contentHeight = 4 + newSize.height + 4;
    self.contentLB.frame = CGRectMake(8, 4, newSize.width, newSize.height);
    
    id chatModel = [(PLVECChatCellModel *)self.model chatModel];
    if (chatModel && [chatModel isKindOfClass:[PLVChatImageModel class]]) {
        PLVChatImageModel *imageModel = (PLVChatImageModel *)chatModel;
        if (imageModel.imageUrl) {
            UIImage *placeholderImage = [PLVECUtils imageForWatchResource:@"plv_chatroom_thumbnail_imag"];
            [self.chatImageView sd_setImageWithURL:[NSURL URLWithString:imageModel.imageUrl]
                                  placeholderImage:placeholderImage
                                           options:SDWebImageRetryFailed];
        }
        if (cellModel.cellWidth - 16 - newSize.width < 40) {
            self.chatImageView.frame = CGRectMake(8, 4 + newSize.height + 4, 36, 36);
            contentHeight += 4 + 36;
        } else {
            self.chatImageView.frame = CGRectMake(8 + newSize.width + 4, 4, 36, 36);
            contentWidth += 4 + 36;
            contentHeight = 4 + 36 + 4;
        }
        
        self.chatImageView.hidden = NO;
    } else {
        self.chatImageView.hidden = YES;
    }
    self.bubbleView.frame = CGRectMake(0, 0, contentWidth, contentHeight);
}

#pragma mark - Action

- (void)tapGestureAction:(UIGestureRecognizer *)sender {
    UIImageView *imageView = (UIImageView *)sender.view;
    [self.photoBrowser scaleImageViewToFullScreen:imageView];
}


@end
