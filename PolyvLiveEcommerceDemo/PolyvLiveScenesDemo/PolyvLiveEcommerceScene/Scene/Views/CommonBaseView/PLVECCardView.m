//
//  PLVECCardView.m
//  PolyvLiveEcommerceDemo
//
//  Created by ftao on 2020/5/25.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECCardView.h"

@implementation PLVECCardView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark - Private

- (void)setupUI {
    self.layer.cornerRadius = 10.0;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithWhite:243/255.0 alpha:0.8];
    
    self.iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 16, 16)];
    [self addSubview:self.iconImgView];
    
    self.titleLB = [[UILabel alloc] initWithFrame:CGRectMake(39, 15, 120, 16)];
    self.titleLB.textColor = [UIColor colorWithWhite:51/255.0 alpha:1];
    self.titleLB.textAlignment = NSTextAlignmentLeft;
    self.titleLB.font = [UIFont systemFontOfSize:16];
    [self addSubview:self.titleLB];
}

@end
