//
//  PLVECPalybackHomePageView.m
//  PolyvLiveEcommerceDemo
//
//  Created by ftao on 2020/5/21.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECPalybackHomePageView.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>
#import "PLVECLiveRoomInfoView.h"
#import "PLVECSwitchView.h"
#import "PLVECPlayerContolView.h"
#import "PLVECUtils.h"

@interface PLVECPalybackHomePageView () <PLVPlayerContolViewDelegate, PLVPlayerSwitchViewDelegate>

@property (nonatomic, strong) PLVECLiveRoomInfoView *liveRoomInfoView;
@property (nonatomic, strong) PLVECPlayerContolView *playerContolView;
@property (nonatomic, strong) PLVECSwitchView *switchView;
@property (nonatomic, strong) UIButton *moreButton;

/// 回放视频时长
@property (nonatomic, assign) NSTimeInterval duration;

@end

@implementation PLVECPalybackHomePageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.liveRoomInfoView = [[PLVECLiveRoomInfoView alloc] initWithFrame:CGRectMake(15, 10, 118, 36)];
        [self addSubview:self.liveRoomInfoView];
        
        self.playerContolView = [[PLVECPlayerContolView alloc] init];
        self.playerContolView.delegate = self;
        [self addSubview:self.playerContolView];
        
        self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.moreButton.bounds = CGRectMake(0, 0, 32.0, 32.0);
        [self.moreButton setImage:[PLVECUtils imageForWatchResource:@"plv_more_btn"] forState:UIControlStateNormal];
        [self.moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.moreButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat buttonWidth = 32.f;
    self.moreButton.frame = CGRectMake(CGRectGetWidth(self.bounds)-buttonWidth-15, CGRectGetHeight(self.bounds)-buttonWidth-15-P_SafeAreaBottomEdgeInsets(), buttonWidth, buttonWidth);
    self.playerContolView.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-41-P_SafeAreaBottomEdgeInsets(), CGRectGetMinX(self.moreButton.frame)-8, 41);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_switchView && !_switchView.hidden) {
        _switchView.hidden = YES;
    }
}

#pragma mark - Getter

- (PLVECSwitchView *)switchView {
    if (!_switchView) {
        CGFloat height = 130 + P_SafeAreaBottomEdgeInsets();
        CGRect switchViewFrame = CGRectMake(0, CGRectGetHeight(self.bounds)-height, CGRectGetWidth(self.bounds), height);
        
        _switchView = [[PLVECSwitchView alloc] initWithFrame:switchViewFrame];
        _switchView.titleLable.text = @"播放速度";
        _switchView.selectedIndex = 1;
        _switchView.items = @[@"0.5x", @"1.0x", @"1.25x", @"1.5x", @"2.0x"];
        _switchView.delegate = self;
        [self addSubview:_switchView];
        
        [_switchView setCloseButtonActionBlock:^(PLVECBottomView * _Nonnull view) {
            [view setHidden:YES];
        }];
    }
    return _switchView;
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

- (void)updateVideoDuration:(NSTimeInterval)duration {
    self.duration = duration;
    if (duration >= 0) {
        self.playerContolView.duration = duration;
    }
}

- (void)updatePlayButtonState:(BOOL)playing {
    if (!self.playerContolView.sliderDragging) {
        self.playerContolView.playButton.selected = playing;
    }
}

- (void)updateDowloadProgress:(CGFloat)dowloadProgress playedProgress:(CGFloat)playedProgress currentPlaybackTime:(NSString *)currentPlaybackTime duration:(NSString *)duration {
    self.playerContolView.currentTimeLabel.text = currentPlaybackTime;
    self.playerContolView.totalTimeLabel.text = duration;
    if (!self.playerContolView.sliderDragging) {
        self.playerContolView.progressSlider.value = playedProgress;
    }
}

#pragma mark - Action

- (void)moreButtonAction:(UIButton *)button {
    self.switchView.hidden = NO;
}

#pragma mark - <PLVPlayerContolViewDelegate>

- (void)playerContolView:(PLVECPlayerContolView *)playerContolView switchPause:(BOOL)pause {
    if ([self.delegate respondsToSelector:@selector(homePageView:switchPause:)]) {
        [self.delegate homePageView:self switchPause:pause];
    }
}

- (void)playerContolViewSeeking:(PLVECPlayerContolView *)playerContolView {
    if ([self.delegate respondsToSelector:@selector(homePageView:seekToTime:)]) {
        NSTimeInterval interval = self.duration * playerContolView.progressSlider.value;
        [self.delegate homePageView:self seekToTime:interval];
    }
}

#pragma mark - <PLVPlayerSwitchViewDelegate>

- (void)playerSwitchView:(PLVECSwitchView *)playerSwitchView didSelectItem:(NSString *)item {
    [playerSwitchView setHidden:YES];
    CGFloat speed = [[item substringToIndex:item.length] floatValue];
    speed = MIN(2.0, MAX(0.5, speed));
    if ([self.delegate respondsToSelector:@selector(homePageView:switchSpeed:)]) {
        [self.delegate homePageView:self switchSpeed:speed];
    }
}

@end
