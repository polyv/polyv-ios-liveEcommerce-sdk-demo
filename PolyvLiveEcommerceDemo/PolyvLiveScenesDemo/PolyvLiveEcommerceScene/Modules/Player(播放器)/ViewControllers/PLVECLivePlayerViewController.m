//
//  PLVECLivePlayerViewController.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/23.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECLivePlayerViewController.h"
#import <PolyvFoundationSDK/PLVProgressHUD.h>
#import "PLVECAudioAnimalView.h"
#import "PLVECUtils.h"

@interface PLVECLivePlayerViewController () <PLVLivePlayerPresenterDelegate>

@property (nonatomic, strong) PLVLivePlayerPresenter *presenter;

@property (nonatomic, strong) UIView *backgroundView; // 显示播放背景图
@property (nonatomic, strong) UIImageView *noLiveImgView;
@property (nonatomic, strong) UILabel *noLiveLabel;

@property (nonatomic, strong) UIView *displayView; // 显示视频区域
@property (nonatomic, assign) CGRect displayRect;

@property (nonatomic, strong) PLVECAudioAnimalView *audioAnimalView; // 显示音频模式

@end

@implementation PLVECLivePlayerViewController

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.presenter = [[PLVLivePlayerPresenter alloc] init];
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
    
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.backgroundView];
    
    UIImage *noLiveImage = [PLVECUtils imageForWatchResource:@"plv_skin_player_background"];
    self.noLiveImgView = [[UIImageView alloc] initWithImage:noLiveImage];
    [self.backgroundView addSubview:self.noLiveImgView];
    
    self.noLiveLabel = [[UILabel alloc] init];
    self.noLiveLabel.text = @"暂无直播";
    self.noLiveLabel.textColor = UIColor.whiteColor;
    self.noLiveLabel.textAlignment = NSTextAlignmentCenter;
    self.noLiveLabel.font = [UIFont systemFontOfSize:14.0];
    [self.backgroundView addSubview:self.noLiveLabel];
    
    self.displayView = [[UIView alloc] init];
    self.displayView.backgroundColor = [UIColor blackColor];
    self.displayView.hidden = YES;
    [self.view addSubview:self.displayView];
    
    [self layoutViewsFrame];
}

- (void)layoutViewsFrame {
    CGFloat scale = 16.0 / 9.0;
    self.backgroundView.frame = CGRectMake(0, 130, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) / scale);
    self.noLiveImgView.frame = CGRectMake(CGRectGetWidth(self.backgroundView.bounds)/2-77, CGRectGetHeight(self.backgroundView.bounds)/2-60, 154, 120);
    self.noLiveLabel.frame = CGRectMake(CGRectGetWidth(self.backgroundView.bounds)/2-100, CGRectGetMaxY(self.noLiveImgView.frame)+12, 200, 14);
    
    if (CGRectEqualToRect(self.displayRect, CGRectZero)) {
        self.displayView.frame = self.backgroundView.frame;
    }
}

#pragma mark - Public

- (void)playLive {
    [self.presenter reloadLive:nil];
}

- (void)pauseLive {
    [self.presenter pauseLive];
}

- (void)reloadLive {
    [self.presenter reloadLive:nil];
}

- (void)switchPlayLine:(NSUInteger)Line showHud:(BOOL)showHud {
    PLVProgressHUD *hud = nil;
    if (showHud) {
        hud = [PLVProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
        [hud.label setText:@"加载直播..."];
    }
    [self.presenter switchPlayLine:Line completion:^(NSError * _Nonnull error) {
        if (error && hud) {
            hud.label.text = [NSString stringWithFormat:@"加载直播失败:%@", error.localizedDescription];
        }
        [hud hideAnimated:YES];
    }];
}

- (void)switchPlayCodeRate:(NSString *)codeRate showHud:(BOOL)showHud {
    PLVProgressHUD *hud = nil;
    if (showHud) {
        hud = [PLVProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
        [hud.label setText:@"加载直播..."];
    }
    [self.presenter switchPlayCodeRate:codeRate completion:^(NSError * _Nonnull error) {
        if (error && hud) {
            hud.label.text = [NSString stringWithFormat:@"加载直播失败:%@", error.localizedDescription];
        }
        [hud hideAnimated:YES];
    }];
}

- (void)switchAudioMode:(BOOL)audioMode {
    [self showAudioAnimalView:audioMode];
    [self.presenter switchAudioMode:audioMode];
}

- (void)destroy {
    [self.presenter destroy];
}

#pragma mark - Priveta

- (void)showAudioAnimalView:(BOOL)show {
    if (!self.audioAnimalView) {
        self.audioAnimalView = [[PLVECAudioAnimalView alloc] init];
        self.audioAnimalView.frame = self.displayView.bounds;
        self.audioAnimalView.contentLable.text = @"音频直播中";
        [self.displayView addSubview:self.audioAnimalView];
    }
    [self.audioAnimalView setHidden:!show];
}

#pragma mark - <PLVLivePlayerPresenterDelegate>

- (void)presenter:(PLVLivePlayerPresenter *)presenter livePlayerStateDidChange:(LivePlayerState)livePlayerState {
    if (livePlayerState == LivePlayerStateUnknown || livePlayerState == LivePlayerStateEnd) {
        self.displayView.hidden = YES;
        self.displayRect = self.backgroundView.frame;
        self.displayView.frame = self.displayRect;
    } else {
        self.displayView.hidden = NO;
    }
}

- (void)presenterChannelPlayOptionInfoDidUpdate:(PLVLivePlayerPresenter *)presenter {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerController:codeRateItems:codeRate:lines:line:)]) {
        PLVLiveRoomData *roomData = presenter.roomData;
        [self.delegate playerController:self
                          codeRateItems:roomData.codeRateItems
                               codeRate:roomData.curCodeRate
                                  lines:roomData.lines
                                   line:roomData.curLine];
    }
}

- (void)presenter:(PLVLivePlayerPresenter *)presenter loadMainPlayerFailure:(NSString *)message {
    PLVProgressHUD *hud = [PLVProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    hud.mode = PLVProgressHUDModeText;
    [hud.label setText:@"播放器加载失败"];
    hud.detailsLabel.text = message;
    [hud hideAnimated:YES afterDelay:2];
}

- (void)presenter:(PLVBasePlayerPresenter *)presenter videoSizeChange:(CGSize)videoSize {
    CGSize viewSize = self.view.bounds.size;
    if (videoSize.width == 0 || videoSize.height == 0 || viewSize.width == 0 || viewSize.height == 0) {
        return;
    }
    if (videoSize.width >= videoSize.height) {
        CGFloat width = viewSize.width;
        CGFloat height = width * videoSize.height / videoSize.width;
        self.displayRect = CGRectMake(0, 130, width, height);
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
