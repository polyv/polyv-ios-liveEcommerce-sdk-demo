//
//  PLVECCommodityCell.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/29.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECCommodityCell.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>

@implementation PLVECCommodityCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        
        self.coverImageView = [[UIImageView alloc] init];
        self.coverImageView.layer.cornerRadius = 10.0;
        self.coverImageView.layer.masksToBounds = YES;
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.coverImageView];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = UIColor.whiteColor;
        self.nameLabel.font = [UIFont systemFontOfSize:14.0];
        self.nameLabel.numberOfLines = 2;
        [self addSubview:self.nameLabel];
        
        self.priceLabel = [[UILabel alloc] init];
        self.priceLabel.textColor = [UIColor colorWithRed:1 green:71/255.0 blue:58/255.0 alpha:1];
        self.priceLabel.textAlignment = NSTextAlignmentLeft;
        if (@available(iOS 8.2, *)) {
            self.priceLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightSemibold];
        } else {
            self.priceLabel.font = [UIFont systemFontOfSize:18.0];
        }
        [self addSubview:self.priceLabel];
        
        self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.selectButton.layer.cornerRadius = 13.5;
        self.selectButton.layer.masksToBounds = YES;
        self.selectButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [self.selectButton addTarget:self action:@selector(selectButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.selectButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.coverImageView.frame = CGRectMake(0, 0, CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds));
    CGFloat positionX = CGRectGetMaxX(self.coverImageView.frame) + 10;
    self.nameLabel.frame = CGRectMake(positionX, 0, CGRectGetWidth(self.bounds)-positionX, 40);
    [self.nameLabel sizeToFit]; // 顶端对齐
    self.priceLabel.frame = CGRectMake(positionX, CGRectGetHeight(self.bounds)-25, 200, 25);
    self.selectButton.frame = CGRectMake(CGRectGetWidth(self.bounds)-60, CGRectGetHeight(self.bounds)-28, 60, 28);
}

#pragma mark - Action

- (void)setModel:(PLVECCommodityModel *)model {
    _model = model;
    if (model) {
        self.nameLabel.text = model.name;
        self.priceLabel.text = [NSString stringWithFormat:@"¥ %.2f",model.price];
        self.coverImageView.image = nil;
        self.selectButton.hidden = NO;
        NSString *urlStr = model.cover;
        if (![urlStr hasPrefix:@"http"]) {
            urlStr =  [@"https:" stringByAppendingString:urlStr];
        }
        [PLVFdUtil setImageWithURL:[NSURL URLWithString:urlStr] inImageView:self.coverImageView completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
            if (error) {
                NSLog(@"-setModel:图片加载失败，%@",imageURL);
            }
        }];
        switch (model.status) {
            case 1: { // 上架
                self.selectButton.enabled = YES;
                [self.selectButton setTitle:@"去购买" forState:UIControlStateNormal];
                self.selectButton.backgroundColor = [UIColor colorWithRed:1 green:166/255.0 blue:17/255.0 alpha:1];
            } break;
            case 2: { // 下架
                self.selectButton.enabled = NO;
                [self.selectButton setTitle:@"已下架" forState:UIControlStateNormal];
                self.selectButton.backgroundColor = [UIColor colorWithWhite:205/255.0 alpha:1];
            } break;
            default:
                self.selectButton.hidden = YES;
                break;
        }
    }
}

#pragma mark - Action

- (void)selectButtonAction {
    if (self.model && [self.delegate respondsToSelector:@selector(commodityCell:didSelectButtonBeClicked:)]) {
        [self.delegate commodityCell:self didSelectButtonBeClicked:self.model];
    }
}

@end
