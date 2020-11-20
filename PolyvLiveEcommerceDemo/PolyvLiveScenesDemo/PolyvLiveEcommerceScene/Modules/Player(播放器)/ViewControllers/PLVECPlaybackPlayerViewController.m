//
//  PLVECPlayerViewController.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/23.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECPlaybackPlayerViewController.h"
#import <PolyvFoundationSDK/PLVProgressHUD.h>
#import "PLVECUtils.h"

@interface PLVECPlaybackPlayerViewController () <PLVPlaybackPlayerPresenterDelegate>

@property (nonatomic, strong) PLVPlaybackPlayerPresenter *presenter;

@property (nonatomic, strong) UIView *displayView;
@property (nonatomic, assign) CGRect displayRect;

@end

@implementation PLVECPlaybackPlayerViewController {
    BOOL _playbackProgressFlag;
}

#pragma mark - Setter

- (void)setDelegate:(id<PLVECPlaybackPlayerViewControlDelegate>)delegate {
    _delegate = delegate;
    _playbackProgressFlag = [delegate respondsToSelector:@selector(updateDowloadProgress:playedProgress:currentPlaybackTime:duration:)];
}

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.presenter = [[PLVPlaybackPlayerPresenter alloc] init];
        self.presenter.view = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self.presenter setupPlayerWithDisplayView:self.displayView];
}

- (void)setupUI {
    UIImageView *backgroundImg = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImg.image = [PLVECUtils imageForWatchResource:@"plv_background_img"];
    [self.view addSubview:backgroundImg];
    
    self.displayView = [[UIView alloc] init];
    self.displayView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.displayView];
    
    [self layoutViewsFrame];
}

- (void)layoutViewsFrame {
    if (CGRectEqualToRect(self.displayRect, CGRectZero)) {
        CGFloat scale = 16.0 / 9.0;
        CGFloat width = CGRectGetWidth(self.view.bounds);
        CGFloat height = CGRectGetWidth(self.view.bounds) / scale;
        CGFloat originY = (CGRectGetHeight(self.view.bounds) - height) / 2.0;
        self.displayView.frame = CGRectMake(0, originY, width, height);
    }
}

#pragma mark - Public

- (void)play {
    [self.presenter play];
}

- (void)pause {
    [self.presenter pause];
}

- (void)seek:(NSTimeInterval)time {
    [self.presenter seek:time];
}

- (void)speedRate:(NSTimeInterval)speed {
    [self.presenter speedRate:speed];
}

- (void)destroy {
    [self.presenter destroy];
}

#pragma mark - <PLVPlaybackPlayerPresenterDelegate>

- (void)presenter:(PLVBasePlayerPresenter *)presenter loadMainPlayerFailure:(NSString *)message {
    PLVProgressHUD *hud = [PLVProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    hud.mode = PLVProgressHUDModeText;
    [hud.label setText:@"播放器加载失败"];
    hud.detailsLabel.text = message;
    [hud hideAnimated:YES afterDelay:2];
}

- (void)updateDowloadProgress:(CGFloat)dowloadProgress playedProgress:(CGFloat)playedProgress currentPlaybackTime:(NSString *)currentPlaybackTime duration:(NSString *)duration {
    if (_playbackProgressFlag) {
        [self.delegate updateDowloadProgress:dowloadProgress playedProgress:playedProgress currentPlaybackTime:currentPlaybackTime duration:duration];
    }
}

- (void)presenter:(PLVBasePlayerPresenter *)presenter videoSizeChange:(CGSize)videoSize {
    CGSize viewSize = self.view.bounds.size;
    if (videoSize.width >= videoSize.height) {
        CGFloat width = viewSize.width;
        CGFloat height = width * videoSize.height / videoSize.width;
        CGFloat originY = (CGRectGetHeight(self.view.bounds) - height) / 2.0;
        self.displayRect = CGRectMake(0, originY, width, height);
    } else {
        CGFloat w_h = videoSize.width / videoSize.height;
        CGFloat w_h_base = viewSize.width / viewSize.height;
        CGRect displayerRect = self.view.bounds;
        if (w_h > w_h_base) {
            displayerRect.origin.y = 0;
            displayerRect.size.height = viewSize.height;
            displayerRect.size.width = viewSize.height * w_h;
            displayerRect.origin.x = (viewSize.width - displayerRect.size.width) / 2.0;
        } else if (w_h < w_h_base) {
            displayerRect.origin.x = 0;
            displayerRect.size.width = viewSize.width;
            displayerRect.size.height = viewSize.width / w_h;
            displayerRect.origin.y = (viewSize.height - displayerRect.size.height) / 2.0;
        }
        self.displayRect = displayerRect;
    }
    self.displayView.frame = self.displayRect;
    [self.presenter setPlayerFrame:self.displayView.bounds];
}

@end
