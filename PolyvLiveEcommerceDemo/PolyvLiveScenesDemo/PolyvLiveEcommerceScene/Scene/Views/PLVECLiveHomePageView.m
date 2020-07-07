//
//  PLVECLiveHomePageView.m
//  PolyvLiveEcommerceDemo
//
//  Created by ftao on 2020/5/21.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECLiveHomePageView.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>
#import "PLVECLiveRoomInfoView.h"
#import "PLVECMoreView.h"
#import "PLVECSwitchView.h"
#import "PLVECBulletinView.h"
#import "PLVECRewardView.h"
#import "PLVECGiftView.h"
#import "PLVECUtils.h"

@interface PLVECLiveHomePageView () <PLVECMoreViewDelegate, PLVPlayerSwitchViewDelegate, PLVECRewardViewDelegate>

@property (nonatomic, strong) PLVECLiveRoomInfoView *liveRoomInfoView;

@property (nonatomic, strong) PLVECMoreView *moreView;

@property (nonatomic, strong) PLVECSwitchView *switchLineView;
@property (nonatomic, assign) NSUInteger lineCount;

@property (nonatomic, strong) PLVECRewardView *rewardView;

@property (nonatomic, strong) PLVECGiftView *giftView;
@property (nonatomic, assign) CGRect originGiftViewFrame;

@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UILabel *likeLable;

@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *giftButton;
@property (nonatomic, strong) UIButton *shoppingCardButton;

@end

@implementation PLVECLiveHomePageView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.liveRoomInfoView = [[PLVECLiveRoomInfoView alloc] initWithFrame:CGRectMake(15, 10, 118, 36)];
        [self addSubview:self.liveRoomInfoView];
        
        self.chatroomView = [[PLVECChatroomView alloc] init];
        [self addSubview:self.chatroomView];
        
        self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.likeButton setBackgroundImage:[PLVECUtils imageForWatchResource:@"plv_like_btn"] forState:UIControlStateNormal];
        [self.likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.likeButton];
        
        self.likeLable = [[UILabel alloc] init];
        self.likeLable.textAlignment = NSTextAlignmentCenter;
        self.likeLable.textColor = UIColor.whiteColor;
        self.likeLable.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.likeLable];
        
        self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.moreButton setImage:[PLVECUtils imageForWatchResource:@"plv_more_btn"] forState:UIControlStateNormal];
        [self.moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.moreButton];
        
        self.giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.giftButton setImage:[PLVECUtils imageForWatchResource:@"plv_gift_btn"] forState:UIControlStateNormal];
        [self.giftButton addTarget:self action:@selector(giftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.giftButton];
        
        self.shoppingCardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.shoppingCardButton setImage:[PLVECUtils imageForWatchResource:@"plv_shoppingCard_btn"] forState:UIControlStateNormal];
        [self.shoppingCardButton addTarget:self action:@selector(shoppingCardButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.shoppingCardButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.chatroomView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)-P_BottomOfEdgeInsets());
    CGFloat buttonWidth = 32.0;
    self.moreButton.frame = CGRectMake(CGRectGetWidth(self.bounds)-buttonWidth-15.0, CGRectGetHeight(self.bounds)-buttonWidth-15.0-P_BottomOfEdgeInsets(), buttonWidth, buttonWidth);
    self.giftButton.frame = CGRectMake(CGRectGetMinX(self.moreButton.frame)-48, CGRectGetMinY(self.moreButton.frame), buttonWidth, buttonWidth);
    self.shoppingCardButton.frame = CGRectMake(CGRectGetMinX(self.giftButton.frame)-48, CGRectGetMinY(self.moreButton.frame), buttonWidth, buttonWidth);
    self.likeButton.frame = CGRectMake(CGRectGetMinX(self.moreButton.frame), CGRectGetMinY(self.moreButton.frame)-59, buttonWidth, buttonWidth);
    self.likeLable.frame = CGRectMake(CGRectGetMidX(self.likeButton.frame)-50/2, CGRectGetMaxY(self.likeButton.frame)+3.0, 50.0, 12.0);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_moreView && !_moreView.hidden) {
        _moreView.hidden = YES;
    }
    if (_switchLineView && !_switchLineView.hidden) {
        _switchLineView.hidden = YES;
    }
    if (_commodityView && !_commodityView.hidden) {
        _commodityView.hidden = YES;
    }
    if (_rewardView && !_rewardView.hidden) {
        _rewardView.hidden = YES;
    }
}

#pragma mark - Getter

- (PLVECMoreView *)moreView {
    if (!_moreView) {
        CGFloat height = 130 + P_BottomOfEdgeInsets();
        _moreView = [[PLVECMoreView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds)-height, CGRectGetWidth(self.bounds), height)];
        _moreView.delegate = self;
        _moreView.hidden = YES;
        [self addSubview:_moreView];
        
        [_moreView setCloseButtonActionBlock:^(PLVECBottomView * _Nonnull view) {
            [view setHidden:YES];
        }];
    }
    return _moreView;
}

- (PLVECSwitchView *)switchLineView {
    if (!_switchLineView) {
        _switchLineView = [[PLVECSwitchView alloc] initWithFrame:self.moreView.frame];
        _switchLineView.titleLable.text = @"切换线路";
        _switchLineView.delegate = self;
        [self addSubview:_switchLineView];
        
        [_switchLineView setCloseButtonActionBlock:^(PLVECBottomView * _Nonnull view) {
            [view setHidden:YES];
        }];
    }
    return _switchLineView;
}

- (PLVECCommodityView *)commodityView {
    if (!_commodityView) {
        CGFloat height = 400 + P_BottomOfEdgeInsets();
        _commodityView = [[PLVECCommodityView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds)-height, CGRectGetWidth(self.bounds), height)];
        [self addSubview:_commodityView];
        _commodityView.hidden = YES;
        
        [_commodityView setCloseButtonActionBlock:^(PLVECBottomView * _Nonnull view) {
            [view setHidden:YES];
            if ([view isKindOfClass:PLVECCommodityView.class]) {
                [[(PLVECCommodityView *)view delegate] clearCommodityInfo];
            }
        }];
    }
    return _commodityView;
}

- (PLVECRewardView *)rewardView {
    if (!_rewardView) {
        CGFloat height = 258 + P_BottomOfEdgeInsets();
        _rewardView = [[PLVECRewardView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds)-height, CGRectGetWidth(self.bounds), height)];
        _rewardView.delegate = self;
        [self addSubview:_rewardView];
        
        [_rewardView setCloseButtonActionBlock:^(PLVECBottomView * _Nonnull view) {
            [view setHidden:YES];
        }];
    }
    return _rewardView;
}

- (PLVECGiftView *)giftView {
    if (!_giftView) {
        self.originGiftViewFrame = CGRectMake(-270, CGRectGetHeight(self.bounds)-335-P_BottomOfEdgeInsets(), 270, 40);
        
        _giftView = [[PLVECGiftView alloc] init];
        _giftView.frame = self.originGiftViewFrame;
        [self addSubview:_giftView];
    }
    return _giftView;
}

#pragma mark - Public

- (void)updateChannelInfo:(NSString *)publisher coverImage:(NSString *)coverImage {
    self.liveRoomInfoView.publisherLB.text = publisher;
    [PLVFdUtil setImageWithURL:[NSURL URLWithString:coverImage] inImageView:self.liveRoomInfoView.coverImageView completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
        if (error) {
            NSLog(@"设置头像失败：%@\n%@",imageURL,error.localizedDescription);
        }
    }];
}

- (void)updateWatchViewCount:(NSUInteger)watchViewCount {
    self.liveRoomInfoView.pageViewLB.text = [NSString stringWithFormat:@"%lu",(unsigned long)watchViewCount];
}

- (void)updateLikeCount:(NSUInteger)likeCount {
    NSString *countStr = [NSString stringWithFormat:@"%ld",likeCount];
    if (likeCount > 10000) {
        countStr = [NSString stringWithFormat:@"%ld.%ldw",likeCount/10000,(likeCount%10000)/1000];
    }
    self.likeLable.text = countStr;
}

- (void)updateLineCount:(NSUInteger)lineCount {
    self.lineCount = lineCount;
}

- (void)updatePlayerState:(BOOL)playing {
    if (_moreView) {
        if (!_moreView.isHidden) {
            [_moreView setItemsHidden:!playing];
        }
        if (!_switchLineView.isHidden && !playing) {
            _switchLineView.hidden = YES;
        }
    }
}

- (void)showBulletinView:(NSString *)content {
    PLVECBulletinView *bulletinView = [[PLVECBulletinView alloc] init];
    bulletinView.frame = CGRectMake(15, CGRectGetMaxY(self.liveRoomInfoView.frame)+15, CGRectGetWidth(self.bounds)-30, 24);
    [bulletinView showBulletinView:content duration:5.0];
    [self addSubview:bulletinView];
}

- (void)showLikeAnimation {
    UIImage *heartImage = [PLVECUtils imageForWatchResource:[NSString stringWithFormat:@"plv_like_heart%@_img",@(rand()%4)]];
    if (!heartImage) {
        return;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:heartImage];
    imageView.frame = CGRectMake(5.0, 5.0, 18.0, 15.0);
    [imageView setContentMode:UIViewContentModeCenter];
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = NO;
    [self.likeButton addSubview:imageView];
    
    CGFloat finishX = round(random() % 84) - 84 + (CGRectGetWidth(self.bounds) - CGRectGetMinX(self.likeButton.frame));
    CGFloat speed = 1.0 / round(random() % 900) + 0.6;
    NSTimeInterval duration = 4.0 * speed;
    if (duration == INFINITY) {
        duration = 2.412346;
    }
    
    [UIView animateWithDuration:duration animations:^{
        imageView.alpha = 0.0;
        imageView.frame = CGRectMake(finishX, - 180, 30.0, 30.0);
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
}

- (void)showGiftAnimation:(NSString *)userName giftName:(NSString *)giftName giftType:(NSString *)giftType duration:(NSTimeInterval)duration {
    if (self.giftView.hidden) {
        self.giftView.hidden = NO;
        self.giftView.nameLabel.text = userName;
        self.giftView.messageLable.text = [NSString stringWithFormat:@"赠送 %@",giftName];
        NSString *giftImageStr = [NSString stringWithFormat:@"plv_gift_icon_%@",giftType];
        self.giftView.giftImgView.image = [PLVECUtils imageForWatchResource:giftImageStr];
        [UIView animateWithDuration:.5 animations:^{
            CGRect newFrame = self.giftView.frame;
            newFrame.origin.x = 0;
            self.giftView.frame = newFrame;
        }];
         
        SEL shutdownGiftView = @selector(shutdownGiftView);
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:shutdownGiftView object:nil];
        [self performSelector:shutdownGiftView withObject:nil afterDelay:duration];
    } else {
        [self shutdownGiftView];
        [self showGiftAnimation:userName giftName:giftName giftType:giftType duration:duration];
    }
}

#pragma mark - Private

- (void)shutdownGiftView {
    self.giftView.hidden = YES;
    self.giftView.frame = self.originGiftViewFrame;
}

#pragma mark - Action

- (void)likeButtonAction:(UIButton *)button {
    [self showLikeAnimation];
    if ([self.delegate respondsToSelector:@selector(likeActionInHomePageView:)]) {
        [self.delegate likeActionInHomePageView:self];
    }
}

- (void)moreButtonAction:(UIButton *)button {
    self.moreView.hidden = NO;
    [self.moreView reloadData];
    if ([self.delegate respondsToSelector:@selector(playerIsPlaying)]) {
        BOOL playing = [self.delegate playerIsPlaying];
        [self.moreView setItemsHidden:!playing];
    }
}

- (void)giftButtonAction:(UIButton *)button {
    self.rewardView.hidden = NO;
}

- (void)shoppingCardButtonAction:(UIButton *)button {
    self.commodityView.hidden = NO;
    [self.commodityView.delegate loadCommodityInfo];
}

#pragma mark - <PLVECMoreViewDelegate>

- (NSArray<PLVECMoreViewItem *> *)dataSourceOfMoreView:(PLVECMoreView *)moreView {
    PLVECMoreViewItem *item1 = [[PLVECMoreViewItem alloc] init];
    item1.title = @"音频模式";
    item1.selectedTitle = @"视频模式";
    item1.iconImageName = @"plv_audioSwitch_btn";
    item1.selectedIconImageName = @"plv_videoSwitch_btn";
    
    PLVECMoreViewItem *item2 = [[PLVECMoreViewItem alloc] init];
    item2.title = @"切换线路";
    item2.iconImageName = @"plv_lineSwitch_btn";
    
    return @[item1, item2];
}

- (void)moreView:(PLVECMoreView *)moreView didSelectItem:(PLVECMoreViewItem *)item index:(NSUInteger)index {
    switch (index) {
        case 0: {
            if ([self.delegate respondsToSelector:@selector(homePageView:switchAudioMode:)]) {
                [self.delegate homePageView:self switchAudioMode:item.isSelected];
            }
        } break;
        case 1: {
            moreView.hidden = YES;
            self.switchLineView.hidden = NO;
            if (self.lineCount > 0) {
                if (!self.switchLineView.items || !self.switchLineView.items.count) {
                    NSMutableArray *mArr = [NSMutableArray array];
                    for (int i = 1; i <= self.lineCount; i ++) {
                        [mArr addObject:[NSString stringWithFormat:@"线路%d",i]];
                    }
                    self.switchLineView.items = mArr;
                }
            }
        } break;
        default:
            break;
    }
}

#pragma mark - <PLVPlayerSwitchViewDelegate>

- (void)playerSwitchView:(PLVECSwitchView *)playerSwitchView didSelectItem:(NSString *)item {
    [playerSwitchView setHidden:YES];
    NSUInteger line = [[item substringFromIndex:2] integerValue];
    if ([self.delegate respondsToSelector:@selector(homePageView:switchPlayLine:)]) {
        [self.delegate homePageView:self switchPlayLine:line];
    }
    [self.delegate homePageView:self switchPlayLine:line];
}

#pragma mark - <PLVECRewardViewDelegate>

- (void)rewardView:(PLVECRewardView *)rewardView didSelectItem:(PLVECGiftItem *)giftItem {
    [rewardView setHidden:YES];
    if ([self.delegate respondsToSelector:@selector(homePageView:rewardGift:giftType:)]) {
        NSString *giftType = [giftItem.imageName substringFromIndex:14];
        [self.delegate homePageView:self rewardGift:giftItem.name giftType:giftType];
    }
}

@end
